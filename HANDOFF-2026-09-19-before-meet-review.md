# Tutorial refl review — 2026-09-19

## Latest change: the Tutorial opens with two levels, not one

Tutorial is now **nine** levels. The old first level is split in two, both
posing `2 + 2 ≡ 4`:

1. **"Meet in the middle"** (`id: meet-in-the-middle`) — proof by computation.
   The player walks each endpoint and says where they land. The holes ask for a
   **term**, not a proof.
   - Agda: `begin 2 + 2 ≡⟨⟩ ? ≡⟨⟩ ? ≡⟨⟩ 4 ∎`, every bracket empty. `_≡⟨⟩_`
     asserts only definitional equality and is not one reduction step, so the
     chain may skip as far as computation reaches. Holes are `?0 : ℕ`.
   - Lean: core `conv => lhs` / `conv => rhs` with one `change` each. When both
     sides reach the same term **`conv` closes the goal with no `rfl` typed**,
     so Lean's level 1 matches Agda's in never naming reflexivity.
     (`conv_lhs`/`conv_rhs` are Mathlib and unavailable; `?_` cannot stand for a
     term in `calc` or `show`.)
   - Bend: it has no chain and no way to focus a side, so it *states* the
     meeting point — `{{==} : {?left == ?right : Nat}}`, two `Nat` holes that
     must agree. The lesson says so plainly, shows the `%`-rewrite form that
     does walk one side at a time
     (`%{{==} : {m == lhs : T}} : {_ == rhs : T}`), and points out that the bare
     `{==}` of level 2 solves it too.
2. **"refl"** (`id: refl`, unchanged) — the same statement in one word, with the
   lesson explaining *why*: equality has a single constructor `refl : x ≡ x`,
   and the checker redoes the walk itself when it compares the sides.

Their Agda lemmas must differ — `two-plus-two-by-hand` and `two-plus-two` —
because `renderWorldModule` harvests every level's statement and solution into
one `Refl/World/Tutorial.agda` and has no exclusion flag; two `two-plus-two`
would break `nix build .#agdaSupport` and, through `agdaDir`, the whole flake
check. Lean and Bend are not harvested.

`variable`…`reading-analog` shifted from indices 2–8 to 3–9 (70 files and 7
directories renamed). **Progress and drafts are keyed by `levelKey world id`,
never by index, so nothing was lost.** Two accepted regressions: bookmarked
deep links `#/w/tutorial/l/2..8` now resolve to different levels (routes carry
the index), and players who had finished Tutorial see it read `8 / 9` with
dependent worlds rendered locked — cosmetic only, nothing gates navigation.

Browser test: the case-split step is now keyed off `lmId … == "induction"`
instead of a hard-coded index, "the last level" is `route 9`, and the level-1
assertions follow the new four hints and term-holes.

### Why Lean's level 1 is `conv`, not `calc` (user question, 2026-09-19)

`calc` is the obvious analogue of `≡-Reasoning` and it was tried first. The
user asked why this is not the Lean shape:

```lean
calc (2 : MyNat) + 2
  _ = (succ 1) + 2  := rfl
  _ = ?_            := ?_
  _ = succ 3        := rfl
  _ = 4             := ?_
```

Re-run against Lean 4.30.0 to answer it. Three facts, each checked:

1. **`calc` itself is fine.** The same chain with the middle term written in
   type-checks (exit 0). Nothing is wrong with the chain shape.
2. **`?_` is not Agda's `?`.** It is a *synthetic opaque* metavariable:
   deliberately closed to unification, because its purpose is to stay unsolved
   until the player fills it. So the `rfl` on the next rung is not allowed to
   conclude `?m := succ 3`, and Lean reports
   `Type mismatch / rfl has type ?m.53 = ?m.53 / but is expected to have type
   ?m.43 = succ 3`. One hole and two rungs reproduce it; `calc` is incidental.
   Control: the identical shape with an ordinary, unifiable `(_ : MyNat)` in
   the term slot compiles (exit 0) — which also shows why `_` is useless as a
   level hole, since it is solved silently and leaves nothing to compute and no
   goal to display.
3. **So `calc` can only carry *proof* holes.** `_ = succ (succ 2) := ?_` does
   work and reports `⊢ 2 + 2 = (succ 2).succ` / `⊢ (succ 2).succ = 4`. But that
   is the shape the user rejected for Agda: the terms are all pre-written, so
   nothing is left to work out, and `calc` has no empty justification slot the
   way `≡⟨⟩` does — every rung must read `:= rfl`, handing over level 2's whole
   answer three times before the player gets there. A `calc` chain also reads
   in one direction, so "meeting in the middle" is a fiction there; the two
   halves are just consecutive steps.

`conv` is what actually does the level's job: `lhs` and `rhs` name the two
endpoints *independently*, `change` restates one of them, a wrong term is
rejected (`'change' tactic failed, pattern … is not definitionally equal to
target 2 + 2`), and when both sides arrive at the same term `conv` closes the
goal by itself — so, like the Agda chain closing on `∎`, Lean's level 1 never
types `rfl` either.

**User's own note on this:** they already prefer the Agda shape, "because I can
actually see how I can work from one way or the other". That is the property to
preserve in any future rework of this level: the two endpoints must stay
separately manipulable and visibly converging. It is the reason `conv` was kept
over `calc` even though `calc` is the closer syntactic twin of `≡-Reasoning`.

### Verification of the split

`nix flake check -L`: all green — manifest, check-levels (110 checks, 0 failed;
128 minus the 18 Lean ones the sandbox skips for want of a writable `/etc`),
security, smoke, bend, website, browser, `nixosModules.default`.
`nix run .#verify-local`: 128 checks, 0 failed against the bubblewrapped
provers, `browser: … prover flows passed (all three provers)`, failure/retry and
security passed.

One browser-test bug was found and fixed on the way: the new hint assertion
ended in `h[3].querySelector('pre code')`, and CDP's `returnByValue` serializes
a DOM node as `{}`, so a truthy element never equalled `Bool True`. Any such
assertion must end in `Boolean(…)`.

## Earlier change: meet in the middle on Tutorial → refl

The first level now teaches the move itself, not just the answer. Its shim is a
skeleton with holes that make the player walk `2 + 2` down and `4` down until
the endpoints meet, closing each half with reflexivity:

- **Agda** — prelude gains `open ≡-Reasoning`; the template is
  `begin 2 + 2 ≡⟨ ? ⟩ suc (suc 2) ≡⟨ ? ⟩ 4 ∎`, two holes, both `refl`.
- **Lean** — `calc` with two `?_` steps, meeting at `succ (succ 2)`, both `rfl`.
- **Bend** — Bend has no chain syntax and no chaining combinator in Base, and
  the `%` rewrite needs equations the player has not earned yet, so it states
  the meeting point as the proof's type: `{?meet : {Succ{Succ{2n}} == … }}`,
  closed with `{==}`.

The five hidden hints now end at the meeting point (hint 3), the filled chain
(hint 4) and the collapse to a bare `refl`/`rfl`/`{==}` (hint 5). Hint 5 and the
conclusion explain *why* the short proof suffices — every step held by
computation, so the checker will do the walk itself — and invite the player to
retype the whole proof as that one line and Check again. That is safe:
`Refl.Server` calls `markSolved` only on a Solved verdict and never clears
progress, so re-checking a finished level cannot cost it.

Inventory: the `explicit proof type` syntax item became `chained proof`
(agda `begin, ≡⟨ ⟩, ∎`; lean `calc`; bend2 `{proof : Type}`) with a
`reasoning.md` card per language; `docs/*/explicit-proof.md` are gone. World 1's
`+-right-comm` no longer unlocks `≡-Reasoning` (level 1 does), so its lesson was
reworded to "the steps now carry real justifications" and it keeps `sections`.
The panel still shows five building blocks in every language.

**Bug fixed on the way:** `(proof : Type)` is not an annotation in Bend. Only
braces annotate; the parenthesised form is the operator-namespace marker and its
type term is discarded when no `.method` was parsed. Verified against the real
`bend`: `({==} : {Succ{Zero{}} == Succ{Succ{Succ{Zero{}}}} : Nat})` — a flatly
wrong type — still prints `All terms check.`, while the brace form correctly
fails. The old `bend2-example.bend`, hint 4 of `bend2.md` and
`docs/bend2/explicit-proof.md` all taught that no-op; the example type-checked
by accident. Everything now uses `{proof : Type}`.

Regenerated `Refl/World/Tutorial.agda` (it picks up `open ≡-Reasoning` and the
chain solution) and `Refl/World/Addition.agda` (level title). The browser test
was updated for the renamed building block, the new hint wording, and the fact
that the Agda template now needs two Gives to close.

## Earlier follow-up: GitHub publication requested

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

**Superseded by the meet-in-the-middle change above:** the snapshot below pins
the lesson as it was before it, so it is history, not the current candidate. A
new snapshot, review and deployment approval are required before anything is
pinned or deployed again.

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
