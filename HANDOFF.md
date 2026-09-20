# Meet in the middle review — 2026-09-19

## Scope and revisions

Reviewed Claude's staged tutorial split on refl base
`19bb9b7d177c6c3b53a38d7314b8309189f9616e` and the consumer on `75e231f`.
Retained the startup fix, plugin commands, prover diagnostics, language-specific
lessons, clipboard handling, isolation and deployment configuration.
Historical notes are in `HANDOFF-2026-09-19-before-meet-review.md`,
`HANDOFF-2026-09-19-before-tutorial-review.md` and `HANDOFF-ROLLOUT.md`;
claims there about current links, publication and lesson shapes are superseded.

## Findings by severity

- **High, open for production:** the consumer deployment pipeline lacks a gate
  comparing the candidate against xty's running system and blocking unrelated
  service restarts/reloads. Explicit production approval and this gate are
  required before activation. Preserve backup checks and disabled automatic
  rollback. Protect nginx, PostgreSQL, networking, docxty and other projects.
- **Medium, fixed:** Bend's two annotation holes did not demonstrate separate
  paths from the original endpoints. Checked `Refl.step`, `Refl.arrive` and
  `Refl.meet` now compose named left/right paths. Each intermediate must compute
  to the neighboring endpoint; the helpers cannot assert a false equality.
  Native `%` rewrites are offered as a second approach after completion.
- **Medium, fixed:** insertion changed numeric bookmark destinations and relocked
  downstream worlds for existing players. New links carry stable lesson IDs;
  legacy Tutorial indices 1–8 resolve to their original IDs. The original eight
  lessons satisfy downstream prerequisites, without fabricating completion of
  the new introduction. Draft/progress keys remain unchanged.
- **Medium, fixed:** reflexivity appeared before the intended demonstration,
  and text overstated it as the only way to construct equality proofs. Its
  documentation now appears in lesson 2; bare reflexivity needs definitional
  equality, while hypotheses, lemmas and other proofs can establish equality
  more generally. The primitive remains legal in lesson 1's native alternative.
- **Medium, previously fixed and retained:** immediate navigation could lose a
  draft because reactive text lagged behind the textarea. Departure reads the
  live textarea. Browser tests repeat same-task edits/navigation with Unicode
  and separate language drafts. Existing close/unmount delays remain: no claim
  is made about crash recovery, tab closure or arbitrary network stalls.
- **Low, fixed:** stale deployment/publication guidance and inaccurate claims
  about Bend annotations and supporting combinators. Only `{proof : Type}` is
  a checked Bend annotation; `(proof : Type)` is not a substitute.
- **Unverified:** the real NixOS KVM module test (`nix build .#module-test`)
  requires `/dev/kvm`, absent here. Host tests do not verify VM boot, cgroup
  exhaustion or OOM recovery.

## Implemented teaching

Tutorial has nine levels. First, **Meet in the middle** (`meet-in-the-middle`)
asks for computational paths for `2 + 2 = 4`: empty-bracket Agda reasoning,
Lean `conv`/`change` on each endpoint, and Bend named paths with number holes.
Bend's conclusion offers the native rewrite proof and explains its syntax.
Second, **refl** retains its old identifier and explains why reflexivity alone
proves the same equality. Each track has its own notation, second-argument
addition definition, ordered hints, building blocks and separate `3 + 1`
worked example. Teaching snippets remain separate from canonical solutions.
No wire-protocol or NixOS option changes.

## Verification

- Native `nix develop -c cabal test all --offline`: 71 examples passed
  (10 protocol, 29 content, 32 backend), including route compatibility and
  existing-player prerequisite access.
- `nix flake check -L`: passed (native suites, manifest, website, 110
  in-sandbox content checks, smoke, browser and HTTP/WebSocket security).
  Lean prover sessions are skipped inside the builder, which lacks
  `/etc/localtime`; they are covered by the isolated host run below.
- `nix run .#verify-local`: 128 isolated checks passed, including all three
  languages' solutions, unfinished templates and worked examples. Chromium
  passed with all three provers, as did failure/retry and security tests.
  Logs: `/tmp/refl-meet-isolated.log`; images: `/tmp/refl-meet-browser`.
  A subsequent presentation-only placeholder fix is covered by final flake
  checks in `/tmp/refl-meet-final-flake.log`.
- Browser coverage checks authored proofs, both Bend methods, wrong number
  intermediates independently on each side, unfinished proofs, the second
  lesson's shortcut, pre-Check building blocks/hint order, language selection,
  clipboard behavior, legacy bookmarks and immediate draft navigation.

## Local rollout and production status

Publish the verified refl HEAD, update only the consumer's GitHub refl lock
node, then build Olimpo with `nixos-rebuild build --flake
~/src/etc-nixos-configuration`. Preserve the user's refreshed dependencies and
kernel. `ns` already lives in `configuration-workstation.nix` and expands to
`nixos-rebuild switch --sudo --flake ~/src/etc-nixos-configuration`.
The user performs activation and assesses http://127.0.0.1:3007. Local approval
is pending. Production has not been changed by this work.

## Later production and refl-only rollback

After explicit approval, record xty's actual running system, old refl input
and ExecStart closure; retain the closure as a GC root and back up refl state.
Compare candidate activation effects with that running system; block unrelated
restarts/reloads. Monitor external availability and protected service PIDs.
Keep backup gates and `autoRollback = false` / `magicRollback = false`.

For a refl regression, repin only the old refl input on the current consumer,
build, repeat the service-diff gate, and activate that candidate. Never use
whole-system `--rollback`, which could change unrelated projects. Preserve
player state unless a demonstrated data-format incompatibility requires its
backup; these lesson changes introduce no such format change.
