# Tutorial refl review — 2026-09-19

## Current follow-up: GitHub publication requested

The user regenerated the consumer lock to use current dependencies and switched
Olimpo to `26.11.20260919.20b1ddd` (kernel 6.18.52). Regenerating the lock
discarded the earlier local refl override and selected GitHub `13f600c`, so the
running lesson was still old. The user now explicitly authorizes pushing refl
HEAD to GitHub and consuming it through `github:hhefesto/refl`. Preserve the
user's refreshed unrelated inputs; update only the refl lock node and rebuild.
The earlier local-store pin and no-publication status below are historical.
Production activation on xty still requires separate explicit approval.

`ns` is defined in the consumer's `configuration-workstation.nix`, alongside
`sn`. NixOS generates `/etc/zshrc` from that declaration; it was never edited
directly. The currently activated system already contains the alias. Existing
shells/tmux panes need `exec zsh` to load it.

## Scope and baseline

Only Tutorial → refl is rewritten, across Agda, Lean and Bend. Exercise
statements, identifiers, progress keys and canonical solutions are unchanged.
The lesson teaches constructor numbers, second-argument addition, the equality
proposition/type, an explicit normalized proof and the short reflexivity proof.
A language-filtered building-block panel uses inventory metadata and docs.

Reviewed baseline: refl `13f600c` (including Claude's `4d4bce6`, `b6e1fd8`,
`f529203`); consumer `05765c2` (including `b2fe757`, `35f0cca`, domain move
`b3564d6` and `1b5ee18`). Both branches are **master**, initially clean.
Preserved the router startup fix, plugin commands, prover diagnostics,
per-language teaching, browser coverage, isolation and https deployment.

## Findings by severity

- **High, open for production:** consumer `deployXty` in `flake.nix` checks
  backup health, pure assertions, live service health and builds, then deploys.
  It does not compare candidate changes against the running system or block
  restarts/reloads of shared nginx, PostgreSQL, networking, docxty or other
  unrelated projects. Production remains blocked pending approval AND this gate.
  The previous nginx outage demonstrates the impact (see archive).
- **Medium, reproduced and fixed:** draft persistence relies on a 1 s debounce,
  50 ms delayed socket close and 150 ms delayed page replacement (`Client.hs`,
  `App.hs`, `LevelPage.hs`). New browser checks dispatch edit and navigation in
  the same browser task, including repeated Unicode and per-language drafts.
  The first same-task edit/navigation test restored the previous draft.
  `eoText` can lag behind asynchronous editor input-method processing.
  Departure now reads the live textarea and prioritizes that flush over a
  simultaneous debounce. The repeated Unicode regression passes in Chromium.
  The existing close/unmount delays remain; this is not a guarantee for tab
  closure, process crashes or arbitrary network stalls (no save acknowledgment).
- **Medium, fixed:** the first lesson jumped straight to reflexivity without
  teaching constructor arithmetic or separating proposition from proof.
  Five progressive hints now lead through the reductions, explicit proof,
  then short proof. Both authored snippets are checked through the real UI.
- **Low, fixed:** stale hint gating, branch and deployment/publication prose.
  Both branches are master; https ingress is live; local snapshots do not
  require publication. Historical handoffs are preserved, not current advice.
- **Verification limit:** `packages.module-test` is not part of flake checks.
  Its xchg/log fixes were reviewed but the KVM VM test remains unverified;
  `/dev/kvm` is absent on this host. Native/isolated/browser checks do not
  establish its cgroup exhaustion, VM boot or OOM-recovery assertions.

## Verification / exact snapshot

Native `nix develop -c cabal test all --offline`: 67 examples, zero failures
(6 protocol, 29 content, 32 backend). `nix run .#check-levels`: 122 checks,
zero failures, including Lean outside the sandbox. `nix flake check -L`:
passed after the draft fix (website, manifest, 106 in-sandbox content checks,
Bend, browser, smoke, security and native suites). Lean prover sessions are
explicitly skipped inside the Nix sandbox because it lacks `/etc/localtime`.
Completed isolated host results and immutable snapshot are recorded below.

Production read-only health probe: `{"levels":61,"ok":true}` at
https://refl.hhefesto.dev/api/health. The currently running Olimpo module also
reports 61; that is the previous build, not acceptance of this candidate.

## Local and production status

User requests the consumer NixOS module for local assessment, with the reviewed
snapshot persisted in its refl input, then `nixos-rebuild build --flake
~/src/etc-nixos-configuration`. The user performs the matching `switch --sudo`.
Add `ns` as that switch alias (existing `sn` retained). No activation performed.
After the user switches, verify http://127.0.0.1:3007, then await explicit
approval before xty. Production remains https://refl.hhefesto.dev at the old
revision; no publication or production deployment authorized/performed here.

## Later production procedure / refl-only rollback

Pin the reviewed revision after approval. Keep backup checks and deploy-rs
`autoRollback = false` / `magicRollback = false`. Compare the built candidate
with xty's actual `/run/current-system`, block any unrelated service restart
or reload, and continuously probe public sites and protected service PIDs.
A successful pure check alone is not restart-safety evidence.

Before activation, record the previous refl input and refl service ExecStart
(store closure), retain that closure as a GC root, and back up refl state.
Rollback only refl: repin its previous input on top of the current consumer,
build and pass the same service-diff gate, then activate that candidate.
Do not use whole-system `--rollback`, which can change unrelated projects.
Do not restore old player state unless needed for a demonstrated data-format
incompatibility; these lesson changes introduce none.

## History

- `HANDOFF-2026-09-19-before-tutorial-review.md`: previous general handoff.
- `HANDOFF-ROLLOUT.md`: previous rollout, nginx outage and .dev move evidence.
- Consumer archives retain its pre-review deployment and domain-move history.

## Completed host verification

`REFL_BROWSER_ARTIFACTS=/tmp/refl-reviewed-browser nix run .#verify-local`
passed: 122 isolated prover checks; Chromium with all three provers; lifecycle
failure/retry; HTTP/WebSocket security. Browser coverage checks the actual two
proof snippets rendered in the hints against the server's level restrictions,
wrong terms fail in each language, templates remain unsolved, five hints appear
in computation-first order, five language-specific building blocks appear
before completion, and selectors/history preserve language-specific commands.
Same-task input/navigation restores exact drafts in all three languages,
including five repeated Agda Unicode drafts. No wire protocol or NixOS option
changes. Screenshots were inspected for lesson layout in the light theme.

Logs: `/tmp/refl-flake-review.log`, `/tmp/refl-levels-review.log`,
`/tmp/refl-isolated-review.log`. Screenshots: `/tmp/refl-reviewed-browser/`.
The first failed browser run reproduced the stale draft; the subsequent Nix
and isolated host browser runs both passed after the fix.

## Immutable local candidate

Reviewed implementation commit: `476f27d3d9bb7ebbc3a1ba3a65a2083bfe9223e7`.
Source: `/nix/store/y3vyjacprm8dpkagr5fiy98b10anl36a-source`, NAR hash
`sha256-QzAOP7R3u1meVRKGOB2xToCq9TAcTW/jVDUI9qXvrv0=`; retained by the
`result-reviewed-source` GC root. Subsequent handoff-only commits do not alter
that reviewed source. Consumer `flake.lock` persistently overrides only `refl`
with this snapshot (JSON comparison: sole changed node `refl`). Original remote
input remains `github:hhefesto/refl`; no push or unrelated dependency update.
Previous refl pin for rollback: `f529203020105b3e995833798348307ab80868a4`.

Consumer configuration commit: `188cc609869d70a929c6c4bad882eb86f49a858d`
(subsequent commits only finalize handoff records). It has the requested `ns`
alias, confirmed in the built `etc/zshrc`.

`nixos-rebuild build --flake /home/hhefesto/src/etc-nixos-configuration` passed.
System: `/nix/store/yqsv22fni68nggn5q0iakm088d86yavd-nixos-system-olimpo-26.11.20260831.34ab990`.
Refl ExecStart: `/nix/store/f8lx96yyy0hjswwgsk1h8v25447dw793-refl-site/bin/refl-site`.
Build log: `/tmp/refl-olimpo-build.log`.

**Existing Olimpo configuration drift:** the running system is
`/nix/store/5pghfdayjcpb2vvjbsbxhl5hmn7cb109-nixos-system-olimpo-26.11.20260916.b1b8759`.
The checkout pins older dependencies; a full switch would also change many
unrelated units (including local nginx, PostgreSQL, NetworkManager) and the
next-boot kernel 6.18.52 → 6.18.48. No unrelated lock inputs were changed to
resolve this drift. `/tmp/refl-olimpo-unit-diff.txt` records the comparison.
The user was informed before activation; this build is not a refl-only switch.

Matching activation command, left to the user:
`nixos-rebuild switch --sudo --flake ~/src/etc-nixos-configuration`.
Start a new zsh after switching for `ns`. Local activation/lesson approval and
production approval remain pending. No production deployment or push occurred.
