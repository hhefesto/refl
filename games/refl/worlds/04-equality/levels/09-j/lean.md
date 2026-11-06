---
title: "Matching on rfl is J"
learning_goals:
  - "The eliminator J: to prove `P y p` for every proof `p : x = y`, it suffices to prove `P x rfl`."
  - "Matching `rfl` unifies `y` with `x`."
hints:
  - text: "Press **Goal**: `P y p`. Then `cases p`, and press it again."
  - text: "Now the goal is `P x ⋯`, where `⋯` is the proof `rfl`, which Lean abbreviates. And `d : P x ⋯` is above the line."
  - text: "`cases p` on one line and `exact d` on the next."
example_explanation: |-
  1. Match the equality with `rfl`.
  2. Its two sides become the same, so `P y` becomes `P x`.
  3. Return the supplied evidence. For J, the motive also mentions the equality proof itself.
---
You have now matched on `rfl` in many different ways. Time to state in one line what all of them have in common. That's **J**, and it looks hard only because of how much it says:

```lean
theorem J {A : Type} {x : A} (P : ∀ y, x = y → Prop) (d : P x rfl) {y : A} (p : x = y) : P y p
```

Compare it with `Eq.subst`, from the last level. `Eq.subst` carries a motive across an equation. So does J. The difference is that J's motive can also mention the *proof of the equation itself*, which is why `P` takes two
arguments: an endpoint `y`, and a proof `x = y`.

In words: suppose you want to prove something about every `y` and every proof `p : x = y`. It's enough to prove it in the one case where `y` is `x` and `p` is `rfl`. Everything else follows.

Why? Because `rfl` is the only constructor. The proof is what you'd hope. Press **Goal** before and after `cases p`, and watch how much changes.

<!-- @conclusion -->
`Eq.symm`, `Eq.trans`, `congrArg` and `Eq.subst` are all instances of J, each with its own motive. In Lean, the principle underneath is `Eq.rec`, which is what `cases` builds for you.

From here, Lean and other provers part ways, in a way that's worth seeing.
