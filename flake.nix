{
  description = "The Refl Game — an NNG4-style proof game for Agda, Lean 4 and Bend 2";

  nixConfig = {
    allow-import-from-derivation = true;
    extra-substituters = [ "https://nixcache.reflex-frp.org" ];
    extra-trusted-public-keys = [
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
    ];
  };

  inputs = {
    # Agda 2.8.0 + stdlib 2.3, lean4 4.30.0, ghc 9.10.3 — the same pin as
    # paper-2021-language-derivatives and aanalyzer-classic, so it is cached.
    nixpkgs.url = "github:nixos/nixpkgs/d407951447dcd00442e97087bf374aad70c04cea";
    # The revision whose pkgsCross.ghcjs.haskell.packages.ghc910 builds the
    # reflex client (aanalyzer-classic's nixpkgs-reflex pin).
    nixpkgs-reflex.url = "github:NixOS/nixpkgs/59e69648d345d6e8fef86158c555730fa12af9de";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    # Bend 2 (TypeScript, run by Bun; no build step, no HVM). Source only:
    # upstream has no flake, and its repo-shape gate would reject one.
    bend2 = { url = "github:bendlang/bend"; flake = false; };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.haskell-flake.flakeModule ];
      flake.nixosModules.default = import ./nix/module.nix self;

      perSystem = { self', pkgs, config, system, ... }:
        let
          ghcVer = "ghc910";
          reflexPkgs = import inputs.nixpkgs-reflex { inherit system; };
          jsPkgs = reflexPkgs.pkgsCross.ghcjs.haskell.packages.${ghcVer};

          # ── provers ──────────────────────────────────────────────────────
          agda = pkgs.agda.withPackages (p: [ p.standard-library ]);
          stdlib = pkgs.agdaPackages.standard-library;
          lean = pkgs.lean4;
          # `bend` = bun running the checked-in interpreter. main.ts finds
          # base.bend and guide/GUIDE.md relative to itself, so the whole
          # source tree is referenced, not copied. clang is only for `-o`.
          # Calling main.ts directly also skips upstream's launcher, which
          # phones home and self-updates.
          bend = pkgs.writeShellApplication {
            name = "bend";
            runtimeInputs = [ pkgs.bun pkgs.clang ];
            text = ''exec bun ${inputs.bend2}/bend2/main.ts "$@"'';
          };
          # The .bend support files copied next to every level (`import ./Refl.bend`).
          # Checked once here so a broken prelude fails the build, not a session.
          bendSupport = pkgs.runCommand "refl-bend-support" { nativeBuildInputs = [ bend ]; } ''
            export HOME=$TMPDIR BEND_LIB=$TMPDIR/lib
            mkdir -p $out
            cp ${./languages/bend2}/*.bend $out/
            for f in $out/*.bend; do bend $f; done
          '';
          locale = {
            LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LC_ALL = "en_US.UTF-8";
            TZ = "UTC";   # lean --server reads /etc/localtime otherwise, which the sandbox lacks
          };

          # A private AGDA_DIR so ~/.agda/libraries (stale on this machine) is
          # never read. Same trick as paper-2021-language-derivatives.
          agdaDirWith = libs: pkgs.runCommand "refl-agda-dir" { } ''
            mkdir -p $out
            printf '%s\n' ${pkgs.lib.concatMapStringsSep " " (l: "'${l}'") libs} > $out/libraries
            echo standard-library > $out/defaults
          '';
          agdaDirStdlib = agdaDirWith [ "${stdlib}/standard-library.agda-lib" ];

          # The game's own Agda library (own ℕ/≡/logic, generated world
          # modules), type-checked so its .agdai files ship with it.
          agdaSupport = pkgs.stdenv.mkDerivation ({
            name = "refl-agda-support";
            src = ./languages/agda;
            nativeBuildInputs = [ agda ];
            AGDA_DIR = agdaDirStdlib;
            # Two sessions: the game's own builtins and agda-stdlib's clash.
            buildPhase = "agda Refl/Everything.agda && agda Refl/Reading/Core.agda";
            installPhase = "mkdir -p $out; cp -r . $out/";
          } // locale);
          agdaDir = agdaDirWith [
            "${stdlib}/standard-library.agda-lib"
            "${agdaSupport}/refl-support.agda-lib"
          ];

          # The Lean support library, built with lake; LEAN_PATH for sessions.
          leanSupport = pkgs.stdenv.mkDerivation {
            name = "refl-lean-support";
            src = ./languages/lean;
            nativeBuildInputs = [ lean ];
            buildPhase = ''
              export HOME=$TMPDIR
              want=$(sed -e 's/.*://' -e 's/^v//' lean-toolchain)
              have=$(lean --version | sed -E 's/^Lean \(version ([^,]*),.*/\1/')
              if [ "$want" != "$have" ]; then
                echo "languages/lean/lean-toolchain wants $want but nixpkgs provides $have" >&2
                exit 1
              fi
              lake build
            '';
            installPhase = ''
              mkdir -p $out
              if [ -d .lake/build/lib/lean ]; then cp -r .lake/build/lib/lean/. $out/; else cp -r .lake/build/lib/. $out/; fi
            '';
          };

          # ── frontend (GHC JavaScript backend) ────────────────────────────
          frontendSrc = builtins.path {
            path = ./frontend;
            name = "refl-frontend-source";
            filter = path: _type:
              let rel = pkgs.lib.removePrefix (toString ./frontend + "/") (toString path);
                  top = builtins.head (pkgs.lib.splitString "/" rel);
              in builtins.elem top [ "refl-frontend.cabal" "src" "app" "dev" ];
          };
          protocolJs = jsPkgs.callCabal2nix "refl-protocol" ./common/protocol { };
          frontendJs = (jsPkgs.callCabal2nix "refl-frontend" frontendSrc {
            refl-protocol = protocolJs;
          }).overrideAttrs (_: { dontStrip = true; });

          website = pkgs.runCommand "refl-website" { } ''
            mkdir -p $out/fonts
            cp -r ${frontendJs}/bin/refl-frontend.jsexe/. $out/
            install -m644 ${./index.html} $out/index.html
            install -m644 ${./fonts.css} $out/fonts.css
            cp -r ${./fonts}/. $out/fonts/
            for f in JuliaMono-Regular JuliaMono-Bold; do
              src=$(find ${pkgs.julia-mono}/share/fonts -name "$f.ttf" | head -1)
              [ -n "$src" ] && cp "$src" $out/fonts/ || true
            done
          '';

          games = ./games/refl;
          backend = self'.packages.refl-backend;
          sandbox = args: import ./nix/prover-sandbox.nix ({ inherit pkgs; } // args);
          isolatedAgda = sandbox {
            executable = "${agda}/bin/agda";
            paths = [ agda agdaDir agdaSupport pkgs.glibcLocales ];
            variables = locale // { AGDA_DIR = "${agdaDir}"; };
          };
          isolatedLean = sandbox {
            executable = "${lean}/bin/lean";
            paths = [ lean leanSupport pkgs.glibcLocales ];
            variables = locale // { LEAN_PATH = "${leanSupport}"; };
          };
          isolatedBend = sandbox {
            executable = "${bend}/bin/bend";
            paths = [ bend bendSupport pkgs.glibcLocales ];
            variables = locale // { BEND_NO_TELEMETRY = "1"; };
          };
        in
        {
          # ── native Haskell (backend + shared packages) ───────────────────
          haskellProjects.default = {
            projectRoot = ./.;
            basePackages = pkgs.haskell.packages.${ghcVer};
            settings = {
              refl-backend = { justStaticExecutables = true; };
            };
            autoWire = [ "packages" "checks" "devShells" ];
            devShell = {
              tools = hp: {
                cabal = hp.cabal-install;
                ghcid = hp.ghcid;
                haskell-language-server = hp.haskell-language-server;
              };
              mkShellArgs = {
                nativeBuildInputs = [ agda lean bend pkgs.glibcLocales ];
                shellHook = ''
                  export AGDA_DIR=${agdaDir}
                  export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
                  export LC_ALL=en_US.UTF-8
                  export REFL_AGDA=${agda}/bin/agda
                  export REFL_LEAN=${lean}/bin/lean
                  export REFL_LEAN_PATH=$PWD/languages/lean/.lake/build/lib/lean
                  export REFL_BEND=${bend}/bin/bend
                  export REFL_BEND_PATH=$PWD/languages/bend2
                  export REFL_GAMES=$PWD/games/refl
                  echo "refl dev shell: agda $(agda --version | head -1 | cut -d' ' -f3), lean $(lean --version | sed -E 's/^Lean \(version ([^,]*),.*/\1/'), $(bend --version)"
                  echo "  cabal run refl-server -- --dev --www ./frontend/static-dev   (backend on :8090)"
                  echo "  nix develop .#frontend -c cabal --project-file=cabal-frontend.project run frontend-dev   (UI on :3003)"
                  echo "  (cd languages/lean && lake build)   once, for Lean levels in the dev shell"
                '';
              };
            };
          };

          packages = {
            # Real-VM module test (custom names, cgroup limits, tmpfs cap, prover
            # isolation, OOM recovery). Needs /dev/kvm: `nix build .#module-test`.
            module-test = import ./nix/module-test.nix { inherit self nixpkgs pkgs system; };
            inherit isolatedAgda isolatedLean isolatedBend;
            inherit website agdaSupport leanSupport agdaDir bend bendSupport;
            frontend-js = frontendJs;
            agda = agda;

            manifest = pkgs.runCommand "refl-manifest" locale ''
              mkdir -p $out
              ${backend}/bin/refl-build-manifest ${games} -o $out/manifest.json
            '';

            # The whole thing: server + static site + provers, all from the store.
            site = pkgs.writeShellScriptBin "refl-site" ''
              exec ${backend}/bin/refl-server \
                --www ${website} --games ${games} \
                --agda ${agda}/bin/agda --agda-dir ${agdaDir} \
                --lean ${lean}/bin/lean --lean-path ${leanSupport} \
                --bend ${bend}/bin/bend --bend-path ${bendSupport} "$@"
            '';
            default = self'.packages.site;
            isolated-site = pkgs.writeShellScriptBin "refl-site" ''
              exec ${backend}/bin/refl-server \
                --www ${website} --games ${games} \
                --agda ${isolatedAgda}/bin/refl-prover --agda-dir ${agdaDir} \
                --lean ${isolatedLean}/bin/refl-prover --lean-path ${leanSupport} \
                --bend ${isolatedBend}/bin/refl-prover --bend-path ${bendSupport} "$@"
            '';

            # Content CI: every level's solution must be Solved and its
            # template Unsolved, in every language that has a source.
            check-levels = pkgs.runCommand "refl-check-levels" ({
              nativeBuildInputs = [ agda lean bend ];
              AGDA_DIR = agdaDir;
            } // locale) ''
              export HOME=$TMPDIR
              # lean --server's watchdog opens /etc/localtime; give the sandbox one
              # if it lets us, otherwise check the Lean levels in the dev shell only.
              skip=""
              if ln -s ${pkgs.tzdata}/share/zoneinfo/UTC /etc/localtime 2>/dev/null; then :; else
                echo "note: no writable /etc in the sandbox; Lean levels are checked by 'nix run .#check-levels' in a dev shell" >&2
                skip="--skip lean"
              fi
              ${backend}/bin/refl-check-levels ${games} $skip \
                --agda ${agda}/bin/agda --agda-dir ${agdaDir} \
                --lean ${lean}/bin/lean --lean-path ${leanSupport} \
                --bend ${bend}/bin/bend --bend-path ${bendSupport} | tee $out
            '';
          };

          apps = {
            verify-local = {
              type = "app";
              program = toString (pkgs.writeShellScript "refl-verify-local" ''
                set -euo pipefail
                export PATH=${pkgs.lib.makeBinPath [ pkgs.curl pkgs.coreutils ]}:$PATH
                export FONTCONFIG_FILE=${pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; }}
                export LC_ALL=en_US.UTF-8
                export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
                tmp=$(mktemp -d)
                server=""
                cleanup() {
                  if [ -n "$server" ]; then kill "$server" 2>/dev/null || true; wait "$server" 2>/dev/null || true; fi
                  rm -rf "$tmp"
                }
                trap cleanup EXIT
                ${backend}/bin/refl-check-levels ${games} \
                  --agda ${isolatedAgda}/bin/refl-prover --agda-dir ${agdaDir} \
                  --lean ${isolatedLean}/bin/refl-prover --lean-path ${leanSupport} \
                  --bend ${isolatedBend}/bin/refl-prover --bend-path ${bendSupport}
                ${backend}/bin/refl-browser-test ${pkgs.chromium}/bin/chromium \
                  ${self'.packages.isolated-site}/bin/refl-site ${games}
                ${self'.packages.isolated-site}/bin/refl-site --port 8125 --data-dir "$tmp" --idle-seconds 2 &
                server=$!
                for i in $(seq 1 100); do
                  curl -fs http://127.0.0.1:8125/api/health >/dev/null && break
                  sleep 0.2
                done
                ${backend}/bin/refl-security-test
              '');
            };
            default = { type = "app"; program = "${self'.packages.site}/bin/refl-site"; };
            serve = { type = "app"; program = "${self'.packages.site}/bin/refl-site"; };
            bend = { type = "app"; program = "${bend}/bin/bend"; };
            check-levels = {
              type = "app";
              program = toString (pkgs.writeShellScript "refl-check-levels-dev" ''
                export AGDA_DIR=${agdaDir}
                export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
                export LC_ALL=en_US.UTF-8
                exec ${backend}/bin/refl-check-levels "''${1:-games/refl}" \
                  --agda ${agda}/bin/agda --lean ${lean}/bin/lean --lean-path ${leanSupport} \
                  --bend ${bend}/bin/bend --bend-path ${bendSupport} "''${@:2}"
              '');
            };
          };

          checks = {
            inherit website;
            # The Bend 2 contract the plugin relies on, against upstream's own
            # test corpus: a proof by induction runs, a loud hole reports its
            # goal, a quiet hole makes the file incomplete. No network: only
            # `import Base`, which lives next to the interpreter.
            bend = pkgs.runCommand "refl-bend" { nativeBuildInputs = [ bend ]; } ''
              export HOME=$TMPDIR BEND_LIB=$TMPDIR/lib
              t=${inputs.bend2}/tests
              step() { echo "bend: $1"; }
              step version;  bend --version | tee $TMPDIR/v; grep -q '^bend 2\.' $TMPDIR/v
              step add_comm; bend $t/proof/add_comm.bend > $TMPDIR/out; grep -qx '{==}' $TMPDIR/out
              step loud-hole; if bend $t/check/hole_named.bend > $TMPDIR/hole 2>&1; then echo "a hole must not check" >&2; exit 1; fi
              grep -q '^- expected : {Nat.add(n, 0n) == n : Nat}' $TMPDIR/hole
              grep -q '^- observed : ?help' $TMPDIR/hole
              grep -q '^Context:' $TMPDIR/hole
              step quiet-hole; if bend $t/check/hole_todo.bend > $TMPDIR/todo 2>&1; then echo "a TODO must not check" >&2; exit 1; fi
              grep -q '^Error: 1 TODO found\.' $TMPDIR/todo
              step level-shape
              cat > $TMPDIR/level.bend <<'BEND'
              import Base

              law two_plus_two:
                {Nat.add(2n, 2n) == 4n : Nat}

              def two_plus_two():
                {==}
              BEND
              sed -i 's/^              //' $TMPDIR/level.bend
              bend $TMPDIR/level.bend > $TMPDIR/level.out 2>&1; grep -q 'All terms check' $TMPDIR/level.out
              cp $TMPDIR/v $out
            '';
            browser = pkgs.runCommand "refl-browser" ({
              nativeBuildInputs = [ pkgs.chromium pkgs.curl ];
              # Chromium's renderer aborts in Skia without a fontconfig setup
              # (the sandbox has no /etc/fonts); give it one real font.
              FONTCONFIG_FILE = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
            } // locale) ''
              export HOME=$TMPDIR
              # lean --server needs /etc/localtime; skip its sessions only where the sandbox refuses
              if ln -s ${pkgs.tzdata}/share/zoneinfo/UTC /etc/localtime 2>/dev/null; then :; else export REFL_BROWSER_SKIP_LEAN=1; fi
              ${backend}/bin/refl-browser-test ${pkgs.chromium}/bin/chromium \
                ${self'.packages.site}/bin/refl-site ${games}
              echo ok > $out
            '';
            check-levels = self'.packages.check-levels;
            manifest = self'.packages.manifest;
            # The server answers, serves the manifest and the client.
            # The HTTP/WebSocket contract (identities, origins, isolation, capacity,
            # message size, idle timeout) against the plain site; the isolated
            # provers cannot start inside the Nix builder (see apps.verify-local).
            security = pkgs.runCommand "refl-security" ({ nativeBuildInputs = [ pkgs.curl ]; } // locale) ''
              export HOME=$TMPDIR
              ${backend}/bin/refl-server --www ${website} --games ${games} \
                --port 8125 --data-dir $TMPDIR/data --idle-seconds 5 --agda ${agda}/bin/agda --agda-dir ${agdaDir} \
                --bend ${bend}/bin/bend --bend-path ${bendSupport} &
              server=$!
              trap 'kill $server 2>/dev/null || true' EXIT
              for i in $(seq 1 100); do
                curl -fs http://127.0.0.1:8125/api/health >/dev/null 2>&1 && break
                sleep 0.2
              done
              ${backend}/bin/refl-security-test
              echo ok > $out
            '';
            smoke = pkgs.runCommand "refl-smoke" ({ nativeBuildInputs = [ pkgs.curl ]; } // locale) ''
              export HOME=$TMPDIR
              ${backend}/bin/refl-server --www ${website} --games ${games} \
                --port 8123 --data-dir $TMPDIR/data --agda ${agda}/bin/agda \
                --bend ${bend}/bin/bend --bend-path ${bendSupport} &
              server=$!
              trap 'kill $server 2>/dev/null || true' EXIT
              for i in $(seq 1 100); do
                curl -fs http://127.0.0.1:8123/api/health >/dev/null 2>&1 && break
                sleep 0.2
              done
              step() { echo "smoke: $1"; }
              step health;   curl -fsS http://127.0.0.1:8123/api/health   -o $TMPDIR/health.json;   grep -q '"ok":true' $TMPDIR/health.json
              step manifest; curl -fsS http://127.0.0.1:8123/manifest.json -o $TMPDIR/manifest.json; grep -q '"mWorlds"' $TMPDIR/manifest.json
              step index;    curl -fsS http://127.0.0.1:8123/              -o $TMPDIR/index.html;    grep -q '<script' $TMPDIR/index.html
              step bundle;   curl -fsS http://127.0.0.1:8123/all.js        -o $TMPDIR/all.js;        test -s $TMPDIR/all.js
              step fallback; curl -fsS http://127.0.0.1:8123/w/tutorial    -o $TMPDIR/deep.html;     grep -q '<script' $TMPDIR/deep.html
              echo ok > $out
            '';
          };

          # Native reflex shell for the jsaddle-warp dev runner.
          devShells.frontend =
            let hp = reflexPkgs.haskell.packages.${ghcVer};
            in pkgs.mkShell {
              nativeBuildInputs = [
                (hp.ghcWithPackages (p: [
                  p.reflex-dom-core p.jsaddle-warp p.jsaddle p.ghcjs-dom p.reflex
                  p.aeson p.lens p.network-uri p.data-default p.text p.containers
                ]))
                hp.cabal-install
              ];
            };
        };
    };
}
