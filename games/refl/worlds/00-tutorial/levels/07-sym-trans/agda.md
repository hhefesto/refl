---
example_explanation: |-
  1. Draw the endpoints: `a → b` and `c → b`.
  2. Reverse the second edge to obtain `b → c`.
  3. Compose with `trans`. The exercise reverses a different edge; match endpoints before composing.
hints:
- hidden: false
  text: To compose equalities, the end of the first must be the start of the second.
- hidden: true
  text: The equation `p` starts at `y`, while your goal starts at `x`. Decide which
    edge needs reversing.
- hidden: true
  text: Build `trans … q`, filling the first argument with an equality starting at
    `x`.
learning_goals:
- '`sym : x ≡ y → y ≡ x` flips an equation; `trans : x ≡ y → y ≡ z → x ≡ z` chains
  two.'
- Read a lemma's type to know which argument goes where.
title: sym and trans
---
To compose equalities, the end of the first must be the start of the second.

Two more inventory lemmas, both proved by pattern matching on `refl`:

```agda
sym   : ∀ {A : Set} {x y : A}   → x ≡ y → y ≡ x
trans : ∀ {A : Set} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
```

This level is a small exercise in reading types: which equation goes where.
Use **Refine** with `trans` to let Agda open the argument holes for you.


<!-- @conclusion -->

Chains of `trans` get unreadable fast. World 1 unlocks `≡-Reasoning`, the
`begin … ≡⟨ … ⟩ … ∎` notation that is just `trans` with the intermediate
terms written out.
