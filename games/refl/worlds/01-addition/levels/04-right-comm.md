---
id: right-comm
index: 4
title: "+-right-comm"
learning_goals:
  - "A `≡⟨ ⟩` step can carry a real lemma, not only `refl`."
  - "Plan the intermediate terms of a chain first, then fill in the justifications."
  - "Operator sections: `(x +_)` is `λ y → x + y`."
unlocks:
  lemmas:
    - name: "+-right-comm"
      agda: "+-right-comm"
      lean: "add_right_comm"
      doc: "plus-right-comm.md"
  syntax:
    - name: "sections"
      doc: "sections.md"
hints:
  - text: "Select each hole and press **Goal**. The first says `x + y + z ≡ x + (y + z)`, which is a lemma you have, word for word."
  - text: "The second says `x + (y + z) ≡ x + (z + y)`. The `x +` stays put and only `y + z` changes: that's `+-comm y z`, under `cong (x +_)`. The third is the first one's shape, backwards."
  - text: "The three holes are `+-assoc x y z`, `cong (x +_) (+-comm y z)` and `sym (+-assoc x z y)`."
---
You met `≡-Reasoning` in the very first level, where every step was computation:

```agda
begin
  a ≡⟨ p ⟩
  b ≡⟨ q ⟩
  c ∎
```

Here `p : a ≡ b` and `q : b ≡ c`. In that first level the brackets stayed empty,
because `≡⟨⟩` means "these compute to the same thing". Here they don't, so each
step needs a real lemma, and the brackets are where it goes.

The statement moves `z` past `y`: `(x + y) + z ≡ (x + z) + y`. There is no
induction this time. You already know addition is associative and commutative, so
it is only a matter of rearranging, and the template gives you the plan. Each line
is a sum, each hole is the reason for one step, and **Goal** on a hole tells you
exactly which equation that step needs.

One step changes only part of a sum, which is where a new piece of notation comes
in. A **section** is an operator with one side missing: `(x +_)` means
`λ y → x + y`, the function that adds `x` on the left. So `cong (x +_) e` applies
`e` underneath the `x +`.

<!-- @conclusion -->
From now on, every proof longer than one `trans` should be a `begin` block. Real
Agda code is full of them, because the intermediate terms are what make a long
proof readable afterwards.
