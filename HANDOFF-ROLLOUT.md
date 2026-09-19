# Refl rollout handoff — 2026-09-18 (evening)

Read this before the historical `HANDOFF.md`. It supersedes that file's
descriptions of lesson pages, hints and drafts.

## State

- `github:hhefesto/refl` (public) is the source the consumer flake
  `~/src/etc-nixos-configuration` pins (input `refl`, no `follows`: the
  provers keep their own nixpkgs pins).
- **olimpo**: `refl.service` on http://127.0.0.1:3007 (loopback, ingress off).
- **xty** (production, 62.238.6.4): profile enabled on branch `refl-xty`,
  plain http on the public address, port 3007 open in the firewall, ingress
  off because hhefesto.com DNS is still being repaired. Deployment goes
  through `nix run .#deploy-xty` (docxty backup health → pure checks → live
  checks → build → deploy-rs). See "Rollout log" below for what actually
  happened.
- When DNS is back: set `hostname = "refl.hhefesto.com"`, `ingress.enable =
  true`, drop `openFirewall`, create the A record, and keep the ACME order
  unit out of activation until the record resolves (as done for aaspectra).

## What the Codex pass added (commit `985ff80`) and what the review changed

Kept: the NixOS module (`nix/module.nix`, `services.refl.profile.*`), the
bubblewrap prover sandbox (`nix/prover-sandbox.nix`, `packages.isolated-site`),
per-browser identities (random 256-bit cookie, exact WebSocket Origin, per-player
progress files under `<data-dir>/players/`), bounds (sessions, message size,
command and idle deadlines, process-group kills), the HTTP/WebSocket security
suite (`refl-security-test`), the `exampleProblems` gate on worked examples,
BSD-3 licence and font notices, hints openable before any Check (user
decision).

Corrected in the review commit:

- **Cookie policy follows the origin** (`Refl.Server.Identity.cookiePolicy`):
  `__Host-refl; Secure` on https and loopback, plain `refl` without `Secure`
  on public http — browsers do not store Secure cookies on
  `http://62.238.6.4`, and the WebSocket handshake rejects cookieless clients,
  so the game could not have opened on the bare IP. `--origin` also reads
  `REFL_ORIGIN`.
- **Drafts** are debounced 1 s again and flushed on Check and on leaving the
  page, instead of one WebSocket message and one progress-file rewrite per
  keystroke under a global lock.
- **Lesson pages are optional overrides again** (the hybrid the user chose):
  Codex had copied all 45 level files verbatim into `agda.md` and required a
  complete page per language. `agda.md` is back to `example_explanation`
  only; the level `.md` is the source of shared prose and hints;
  `teachingProblems` checks the *effective* prose.
- A corrupt player file degrades to empty progress (logged) instead of a
  permanent 500.
- Module: `backend.address` is any address, `backend.openFirewall`,
  `hostname` has no default (required with ingress), `ExecStart` unchanged.
- `checks.security` runs the security suite against the plain site inside
  the Nix builder; `checks.nixos` became `packages.module-test`.

## The VM test (`packages.module-test`)

Codex reported it failing with "timeout / missing test.log". Causes found:

1. `qemu-vm.nix` always exports `$TMPDIR/xchg` (and `SHARED_DIR`) over virtfs;
   the runner only created the results directory, so QEMU refused to start.
   Fixed (`nix/module-test.nix`).
2. The `tee` log was never flushed before `poweroff --no-block`. Fixed.
3. **olimpo has no `/dev/kvm`**: `kvm` is loaded with 0 users and `kvm_amd`
   is not, although the CPU reports `svm` and the hardware config lists
   `kvm-amd`. Probably SVM is disabled in the BIOS. Under TCG the boot alone
   blows the 1200 s budget, so the test is a package with
   `requiredSystemFeatures = [ "kvm" "nixos-test" ]`, not a check. Run
   `nix build .#module-test` on a host with KVM.

## How to re-verify

```sh
cd ~/src/refl && nix develop
cabal build all && cabal test all             # 6 + 32 + 29 examples
cabal run refl-build-manifest -- games/refl -o /tmp/m.json   # authoring laws
git add -A && nix flake check -L              # website, manifest, check-levels, smoke, security, bend, browser
nix run .#verify-local                        # isolated provers: 122 checks, browser, security
```

Against a live service (never starts or stops it, writes under a fresh
identity):

```sh
nix build --inputs-from . nixpkgs#chromium -o result-browser-tools
REFL_BROWSER_EXISTING_URL=http://62.238.6.4:3007 FONTCONFIG_FILE=/etc/fonts/fonts.conf \
  cabal run refl-browser-test -- result-browser-tools/bin/chromium unused games/refl
```

## Known limits (not blockers)

- `--max-sessions` is a global counter: four open sockets from one client
  fill the server. Raise `limits.sessions` with more RAM.
- Idle sessions close after `--idle-seconds` (300); the client offers Retry.
- Each cookieless HTTP request mints an identity; the SPA's parallel first
  load can discard one. Harmless.
- Nothing prunes `players/*.json`.
- The ingress vhost listens on IPv4 only and lacks the repo's usual HSTS and
  `limit_req` headers; add them when DNS returns.

## Rollout log

(filled in below as the xty deployment proceeds)

2026-09-18/19, before the deploy (all run from `~/src/etc-nixos-configuration`,
branch `refl-xty`, commit `b2fe757`, refl input `f529203`):

- refl: `cabal test all` 6 + 32 + 29; `nix flake check` exit 0 (website,
  manifest, check-levels 106 in-sandbox, smoke, security, bend, browser);
  `nix run .#verify-local` 122 isolated checks, browser with all three
  provers, security suite. gitleaks: no leaks.
- consumer: `nix run .#check-docxty-backups` passed (timer live, last run ok,
  snapshot 17 h old with the dump, restic check clean);
  `checks.pre-deploy-xty` passed (incl. the refl assertions);
  `nix run .#pre-deploy-xty-live` passed; xty toplevel built
  (`idkr94pg…-nixos-system-xty-26.11.20260831.34ab990`, 11.1 GiB closure);
  unit diff against the running generation: only `refl.service` added;
  kernel 6.12.74 → 6.18.48 (new kernel needs a reboot to take effect; the
  switch itself does not reboot).
