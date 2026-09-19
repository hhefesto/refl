# Refl review and local module handoff — 2026-09-18

Read this before the historical `HANDOFF.md`. It supersedes that file's optional
teaching, post-Check hints and debounced-draft descriptions.

## Current result: working through the module on Olimpo

The user successfully activated the tested configuration with:

```sh
nixos-rebuild switch --sudo --flake ~/src/etc-nixos-configuration#olimpo
```

`refl.service` is active at **http://127.0.0.1:3007**. The **live service** passed
Chromium acceptance in Agda, Lean and Bend, including enabled Check, proof
completion, Give/case splits where supported, both language selectors, history
navigation, inventory isolation, immediate draft saves, hints before Check,
themes and persistence. The test used a fresh browser identity and did not start,
stop or restart the service. Log: `/tmp/refl-module-browser.log`.

Verified active system and successful full host build:
`/nix/store/5pghfdayjcpb2vvjbsbxhl5hmn7cb109-nixos-system-olimpo-26.11.20260916.b1b8759`.

The consumer's `olimpo.nix` imports `inputs.refl.nixosModules.default` and enables
`services.refl.profile` on `127.0.0.1:3007`, with ingress disabled. The input is an
immutable snapshot of tracked source:
`path:/nix/store/p0fl9zyk6lpyaas9shwnpij91xv11zv0-refl-local-source`.
`result-local-source` protects it from garbage collection. Later working-tree
edits do not change the running service. Refresh the snapshot/pin and rebuild
before switching changes; replace this machine-local input with a published Git
revision before sharing or deploying. Prover packages retain this flake's pins.

Existing consumer workstation edits, Cardano configuration and dependency updates
were preserved. Comparison against the saved pre-integration lock confirmed no
existing locked input was removed/changed (Nix renamed some lock node keys).
The local host candidate includes those pre-existing edits; it is not an xty
rollout candidate. The agent performed builds and checks without sudo. Only the
user performed host activation.

## Module behavior and limits

`nixosModules.default` exports typed `services.refl.profile` options for service
name, user/group, state/runtime directory names, loopback address/port, hostname,
optional ingress ports and resource limits. Defaults:

- Service/user/group `refl`; state `/var/lib/refl`, runtime `/run/refl`, mode 0700.
- 2 GiB aggregate RAM, zero swap, one CPU quota, 128 tasks, four sessions.
- 256 MiB service temporary filesystem; each isolated prover has 16 MiB scratch.
- 64 KiB incoming messages, 120-second command deadline, 300-second idle timeout.
- No PostgreSQL dependency; nginx/ACME/firewall changes only with opt-in ingress.

Actual active-service cgroups read back as `memory.max=2147483648`,
`memory.swap.max=0`, `cpu.max=100000 100000`, `pids.max=128`. No OOM events were
recorded during the live browser suite. Exhaustion/recovery is not yet proven by
the disposable VM test (see remaining work).

Provers use bubblewrap with fresh user/network/PID/mount namespaces, cleared
environment, read-only pinned tool closures and only their own session directory
writable. Host state and sibling session directories are not mounted.

Two integration bugs were reproduced and fixed:

1. `AF_NETLINK` must be allowed so bubblewrap can configure isolated loopback.
   Otherwise Agda exits on NETLINK_ROUTE socket creation and Check stays disabled.
2. `ProtectKernelTunables=true` masks host `/proc` entries, preventing nested
   unprivileged procfs mounts. It is disabled; `/sys` is explicitly read-only,
   host capabilities remain empty, and each prover mounts its own `/proc`.
   Disposable user-service comparison reproduced failure with true and successful
   startup with false. Both fixes were then tested together before the last switch.

## Review/application changes

- Preserved earlier frontend startup fixes, diagnostics, plugin-provided command
  capabilities, Bend support, lesson improvements, browser harness and themes.
- Progressive hints work before Check. Drafts queue on each editor edit;
  acceptance navigates before the former two-second debounce could expire.
- All 61 playable variants require complete language-specific teaching. Explicit
  Agda pages retain existing hand-written prose; manifests never use Agda as a
  fallback for another language. Shared curriculum order remains teaching and
  presentation, then language derivatives, then Felix.
- Complete worked examples are checked against effective restrictions, including
  extra imports/options and forbidden vocabulary. Fixed excess imports and two
  examples that relied on the theorem being taught. Exercise solutions stay out
  of published manifests.
- Browser progress/drafts and WebSocket sessions use random 256-bit identities
  in host-only `__Host-refl` cookies (Secure, HttpOnly, SameSite=Strict). Legacy
  shared progress is not assigned to browsers. Disk updates are serialised and
  atomic; no unbounded player cache. WebSocket Origin must exactly match the
  configured origin, so use `http://127.0.0.1:3007` locally.
- Added bounds, process-group cleanup, isolated prover packages and module tests.
- Added BSD-3-Clause LICENSE, font notices and upstream OFL license files.

## Checks actually run

- `nixos-rebuild build --flake ~/src/etc-nixos-configuration#olimpo`: passed;
  the user switched it, and `/run/current-system` matches the built generation.
- `nix develop --command cabal test all --offline`: passed: 29 content,
  6 markdown and 31 backend examples.
- `nix run .#verify-local`: passed all 122 exercise/worked-example checks through
  isolated Agda, Lean and Bend (outside the Nix builder), Chromium acceptance and
  the real HTTP/WebSocket security suite.
- A disposable systemd user service with the corrected module restrictions and
  resource limits passed security and browser suites; stopped automatically.
  Log: `/tmp/refl-module-probe.log`. Security includes independent identities,
  cookie attributes, progress/draft isolation, origins, capacity, message sizes,
  idle expiration and reuse after disconnect.
- Live module browser acceptance: passed all three provers. Existing-service mode
  deliberately skips lifecycle/restart checks; ordinary standalone browser
  acceptance covers failure/retry. Chromium retained at `result-browser-tools`.
- Manifest generation succeeded with teaching validation for all 61 variants.
- Reachable Git history audit: gitleaks checked 11 commits, no findings. A final
  working-tree/history publication audit is still required.
- `git diff --check`: passed in both repositories.
- **`checks.nixos` has not passed.** The disposable VM test failed (timeout/missing
  shared test log). It is intended to cover custom names/ports, composition,
  isolation, temporary exhaustion, OOM recovery and cleanup. Do not report a green
  full flake check or claim exhaustion coverage until this is fixed and rerun.

To rerun browser acceptance against the live module after building the harness:

```sh
nix develop --command cabal build exe:refl-browser-test --offline
nix build --inputs-from . nixpkgs#chromium -o result-browser-tools
REFL_BROWSER_EXISTING_URL=http://127.0.0.1:3007 \
  FONTCONFIG_FILE=/etc/fonts/fonts.conf \
  cabal run refl-browser-test -- result-browser-tools/bin/chromium unused games/refl
```

## Operational lessons and remaining rollout work

- Build/evaluate as the user; use `--sudo` only for switch. The old active `sn`
  alias evaluated everything as root, failing to fetch private xpsOasis. The
  consumer already fixes that alias; existing shells may still need reloading.
- Do not lock a changing absolute `path:` checkout and keep editing before a
  switch: this caused a NAR hash mismatch. Use an immutable snapshot or Git pin.
- Keep test executables rooted: Chromium dependencies disappeared during an
  earlier attempt, producing ICU failures unrelated to Refl.
- No publication, xty activation, DNS change, nginx/ACME change, reboot or rollback
  has been performed. Changes remain uncommitted/unpublished.
- Before publication/production: finish VM resource/isolation/cleanup tests and
  security review, final secret audit, review/commit, create public `hhefesto/refl`
  and replace local input with the published immutable revision.
- For xty: use a clean branch from a verified live baseline; exclude unrelated
  Cardano/dependency changes. Preserve backup checks and disabled automatic
  rollback. Gate any activation against docxty/PostgreSQL/shared nginx/networking
  or unrelated application restarts, and continuously probe docxty externally.
  If the gate cannot pass, leave the build artifact unactivated.
- GoDaddy DNS recovery and safe public ingress remain launch prerequisites.
- Refl-only rollback: stop/disable its profile/service or restore its prior pin,
  preserving `/var/lib/refl`. Do not roll back the whole host to undo Refl.
