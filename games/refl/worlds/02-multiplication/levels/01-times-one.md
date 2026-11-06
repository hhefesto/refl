---
id: times-one
index: 1
title: "*-one"
learning_goals:
  - "Unfold a definition by hand: `x * 1` is `x * zero + x`, which is `zero + x`."
  - "Reuse `zero-+`."
unlocks:
  lemmas:
    - name: "*-one"
      bend2: "Multiplication.mul_one"
      agda: "*-one"
      lean: "mul_one"
hints:
  - text: "Select the hole and press **Goal**. It says `0 + x ≡ x`. You have seen that equation before."
  - text: "`*-one x = zero-+ x`."
---
Multiplication works like addition: it looks at its **second** argument.

```agda
m * zero  = zero
m * suc n = m * n + m
```

So a multiplication with a known number on the right computes, even with a variable
on the left. Follow it through for `x * 1`, remembering that `1` is `suc zero`.
First the second clause, then the first.

Do that on paper, then check yourself: select the hole, type `x * 1` in the box and
press **Normalise**. It stops before reaching `x`. Addition has got in the way, and
it is stuck, since addition can't see through a variable on the right.

But that stuck term isn't new. Nothing here needs an induction: one lemma from your
inventory finishes it.

<!-- @conclusion -->
`x * zero ≡ zero` holds by computation and never needs a lemma, just like
`x + zero ≡ x`. And `x * 1` very nearly computes to `x`, except for that `zero +`
left over, which you had to pay for back in the Tutorial.
