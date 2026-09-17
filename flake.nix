{
  description = "The Refl Game — an NNG4-style proof game for Agda, Lean 4 and (later) Bend2";

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
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { self', pkgs, config, system, ... }:
        let
          ghcVer = "ghc910";
          reflexPkgs = import inputs.nixpkgs-reflex { inherit system; };
          jsPkgs = reflexPkgs.pkgsCross.ghcjs.haskell.packages.${ghcVer};

          # ── provers ──────────────────────────────────────────────────────
          agda = pkgs.agda.withPackages (p: [ p.standard-library ]);
          stdlib = pkgs.agdaPackages.standard-library;
          lean = pkgs.lean4;
          locale = {
            LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LC_ALL = "en_US.UTF-8";
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
            buildPhase = "agda Refl/Everything.agda";
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
                nativeBuildInputs = [ agda lean pkgs.glibcLocales ];
                shellHook = ''
                  export AGDA_DIR=${agdaDir}
                  export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
                  export LC_ALL=en_US.UTF-8
                  export REFL_AGDA=${agda}/bin/agda
                  export REFL_LEAN=${lean}/bin/lean
                  export REFL_LEAN_PATH=$PWD/languages/lean/.lake/build/lib/lean
                  export REFL_GAMES=$PWD/games/refl
                  echo "refl dev shell: agda $(agda --version | head -1 | cut -d' ' -f3), lean $(lean --version | sed -E 's/^Lean \(version ([^,]*),.*/\1/')"
                  echo "  cabal run refl-server -- --dev --www ./frontend/static-dev   (backend on :8090)"
                  echo "  nix develop .#frontend -c cabal --project-file=cabal-frontend.project run frontend-dev   (UI on :3003)"
                  echo "  (cd languages/lean && lake build)   once, for Lean levels in the dev shell"
                '';
              };
            };
          };

          packages = {
            inherit website agdaSupport leanSupport agdaDir;
            frontend-js = frontendJs;
            agda = agda;

            manifest = pkgs.runCommand "refl-manifest" { } ''
              mkdir -p $out
              ${backend}/bin/refl-build-manifest ${games} -o $out/manifest.json
            '';

            # The whole thing: server + static site + provers, all from the store.
            site = pkgs.writeShellScriptBin "refl-site" ''
              exec ${backend}/bin/refl-server \
                --www ${website} --games ${games} \
                --agda ${agda}/bin/agda --agda-dir ${agdaDir} \
                --lean ${lean}/bin/lean --lean-path ${leanSupport} "$@"
            '';
            default = self'.packages.site;

            # Content CI: every level's solution must be Solved and its
            # template Unsolved, in every language that has a source.
            check-levels = pkgs.runCommand "refl-check-levels" ({
              nativeBuildInputs = [ agda lean ];
              AGDA_DIR = agdaDir;
            } // locale) ''
              export HOME=$TMPDIR
              ${backend}/bin/refl-check-levels ${games} \
                --agda ${agda}/bin/agda --agda-dir ${agdaDir} \
                --lean ${lean}/bin/lean --lean-path ${leanSupport} | tee $out
            '';
          };

          apps = {
            default = { type = "app"; program = "${self'.packages.site}/bin/refl-site"; };
            serve = { type = "app"; program = "${self'.packages.site}/bin/refl-site"; };
            check-levels = {
              type = "app";
              program = toString (pkgs.writeShellScript "refl-check-levels-dev" ''
                export AGDA_DIR=${agdaDir}
                export LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive
                export LC_ALL=en_US.UTF-8
                exec ${backend}/bin/refl-check-levels "''${1:-games/refl}" \
                  --agda ${agda}/bin/agda --lean ${lean}/bin/lean --lean-path ${leanSupport} "''${@:2}"
              '');
            };
          };

          checks = {
            inherit website;
            check-levels = self'.packages.check-levels;
            manifest = self'.packages.manifest;
            # The server answers, serves the manifest and the client.
            smoke = pkgs.runCommand "refl-smoke" { nativeBuildInputs = [ pkgs.curl ]; } ''
              export HOME=$TMPDIR
              ${backend}/bin/refl-server --www ${website} --games ${games} \
                --port 8123 --data-dir $TMPDIR/data --agda ${agda}/bin/agda &
              server=$!
              trap 'kill $server 2>/dev/null || true' EXIT
              for i in $(seq 1 100); do
                curl -fs http://127.0.0.1:8123/api/health >/dev/null 2>&1 && break
                sleep 0.2
              done
              curl -fs http://127.0.0.1:8123/api/health | grep -q '"ok":true'
              curl -fs http://127.0.0.1:8123/manifest.json | grep -q '"mWorlds"'
              curl -fs http://127.0.0.1:8123/ | grep -q '<script'
              curl -fs http://127.0.0.1:8123/all.js | head -c 100 >/dev/null
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
