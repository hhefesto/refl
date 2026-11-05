---
id: dec-zero
index: 9
title: "A decision with evidence"
learning_goals:
  - "`Dec A` is `yes a` or `no ¬a`: a decision *with evidence*."
  - "Writing a decision means proving something in every case."
hints:
  - text: "**Case split** on `n`. The goals are `Dec (0 ≡ 0)` and `Dec (suc n ≡ 0)`. Which of these is true?"
  - text: "**Refine** with `yes` or `no`, then ask for the new hole's **Goal**. `yes` wants a proof of the equation, and `no` wants a function from the equation to `⊥`."
  - text: "`is-zero zero = yes refl`, and `is-zero (suc n) = no (λ ())`."
---
A function returning a boolean can tell you an answer, but it can't tell you why. Nothing
stops it being wrong. Agda has something better:

```agda
data Dec (A : Set) : Set where
  yes :   A → Dec A
  no  : ¬ A → Dec A
```

A value of type `Dec A` is a decision about the proposition `A`, and it comes with
evidence. Saying `yes` requires a proof of `A`, and saying `no` requires a refutation of
`A`. So a program of type `Dec A` can't give you the wrong answer: the type won't let it.

Start with a simple decision: is this number zero? The statement is
`(n : ℕ) → Dec (n ≡ zero)`.

You can't answer until you know what `n` is, so **Case split** on it. In each clause the
answer is then obvious to you. Your job is to convince Agda: **Refine** with `yes` or `no`
opens a hole for the evidence. You've just learned what the evidence looks like when the
answer is no.

<!-- @conclusion -->
Writing a decision procedure means writing a proof for every case. That's the difference
between `Dec` and a boolean, and the next level needs it: deciding whether *any* two
numbers are equal.
