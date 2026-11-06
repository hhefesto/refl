---
title: "Hedberg: decidable equality gives UIP"
learning_goals:
  - "**UIP**: any two proofs of the same equation are equal."
  - "In Lean it holds for every type, by proof irrelevance."
hints:
  - text: "The goal is `p = q`, with `p` and `q` both proofs of `x = y`."
  - text: "`rfl`."
example_explanation: |-
  1. `p` and `q` are proofs of the same `Prop`.
  2. Lean's kernel treats them as the same term.
  3. So `rfl` closes it, for any `P` at all. The exercise is the case where `P` is an equation.
---
Here's the theorem: any two proofs of the same equation on `MyNat` are equal.

```lean
theorem eq_irrelevant {x y : MyNat} (p q : x = y) : p = q
```

This property is called **UIP**, for *uniqueness of identity proofs*. **Hedberg's theorem** says that any type with decidable equality has it, even in a system where it isn't automatic. The proof goes the way you'd guess from the last level: rebuild `p` from `canon p`, swap `canon p` for
`canon q` (they're equal), and what's left is `q` rebuilt from `canon q`.

In Agda, played without axiom K, that's three steps of real work, and they build on the two levels before this one.

In Lean, it's one word. Try it, and be glad, but also notice the price. Proof irrelevance means you can never tell two proofs of an equation apart, so a whole branch of mathematics that studies exactly that, homotopy type theory, can't be done in Lean's `Prop`.

<!-- @conclusion -->
Every proof assistant makes a choice about what equality is. In Lean's library this fact is `Subsingleton.elim`, or just `rfl`. Agda's `--without-K` makes the opposite choice, and there you'd have to work for it.
