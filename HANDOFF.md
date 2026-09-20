# Meet in the middle review — 2026-09-19

## Scope and revisions

Reviewed Claude's staged tutorial split on refl base
`19bb9b7d177c6c3b53a38d7314b8309189f9616e` and the consumer on `75e231f`.
Verified implementation commit: `1164993` (the following commit updates only
this handoff). Both complete flake runs passed, including the final placeholder
change. Native, isolated and browser results below are complete.
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

## Latest change: one step shown, one step asked (uncommitted)

Level 1 no longer starts each side at its bare endpoint. Every track now
**scaffolds one computation step at each end and asks the player for the next
one**. The user's words for the two holes: "a step of progress from the left and
a step of progress from the right".

```agda
two-plus-two-by-hand =
  begin
    2 + 2           ≡⟨⟩
    suc 1 + suc 1   ≡⟨⟩   -- shown
    ?               ≡⟨⟩   -- yours: suc (suc 1 + 1)
    ?               ≡⟨⟩   -- yours: suc (suc 2)
    suc 3           ≡⟨⟩   -- shown
    4               ∎
```

- **Lean** stacks **two `change`s per `conv` block**, the first shown and the
  second the player's, whose placeholder is `change ?_`. A bare `?_` on its own
  line does not parse inside `conv` (`unexpected token '?'; expected
  'binder_predicate'`) because `?_` is term syntax; as `change`'s argument it
  parses, is a no-op, and leaves `⊢ succ 1 + succ 1 = succ 3` open.
  `change _`, `change ?name` and `skip` were tried and behave identically. This deliberately supersedes the earlier "one `change`
  per side", agreed with the user when the new shape was chosen.
- **Bend** nests one extra `Refl.step` waypoint per path, moving `?left` and
  `?right` outward: shown `Succ{Refl.add(2n, 1n)}` / `Succ{3n}`, asked
  `Succ{Succ{Refl.add(2n, 0n)}}` / `Succ{Succ{2n}}`.

**The asymmetry is real and is now taught.** Agda's two holes may be spelled
differently, because `≡⟨⟩` wants only definitional equality. Lean's two sides
must reach the *same term*: `conv` auto-closes on syntactic agreement at
reducible transparency, so `lhs = succ 1 + succ 1` against `rhs = succ 3` still
reports `unsolved goals` (which is exactly what keeps the template unsolved).
Both Lean shapes were run through `lean` directly before any prose was written.

`Refl/World/Tutorial.agda` was regenerated rather than hand-edited; the
regenerator also restores the trailing newline an earlier hand edit had dropped.

A **Reset** button now sits at the right of the command row. It restores the
level's own template for the current language, clears the verdict, holes, goal
and messages, and replaces the stored draft so the reset survives leaving the
page. It is a client action, not a `CommandId`, so it is never gated by an
unlock. Wiring it means the editor's `ecSetText` now depends on an event bound
after the editor in the same `mdo`; that recursive knot builds fine (the browser
test's first assertion would have caught the blank-page failure mode).

The Lean lesson and `docs/lean/reasoning.md` also gained the **direction** note:
an Agda chain is one column where the left endpoint walks down and the right
walks up to meet in the middle, whereas each Lean `conv` block is its own
downward walk and what must coincide is the last line of the `lhs` block with
the last line of the `rhs` block.

Browser test follow-ups: the hint assertions now key off the standardised
phrases "one step from the left" / "one step from the right" (shared by all
three tracks); the typed chain literal is the shipped six-rung template; the
Give sequences supply the shipped hole answers; and `firstProofs`' corruption
targets now name the *player's* step, with a new guard that fails loudly if a
target string no longer occurs in the authored proof.

## Implemented teaching

Tutorial has nine levels. First, **Meet in the middle** (`meet-in-the-middle`)
asks for computational paths for `2 + 2 = 4`: empty-bracket Agda reasoning,
Lean `conv`/`change` on each endpoint, and Bend named paths with number holes.
Each track shows one step at either end and asks for the next (see the latest
change above).
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
