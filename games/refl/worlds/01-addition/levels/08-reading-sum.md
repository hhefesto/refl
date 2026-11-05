---
id: reading-sum
index: 8
title: "Reading: a finite sum"
learning_goals:
  - "A higher-order function `(ℕ → ℕ) → ℕ → ℕ` defined by recursion."
  - "Lemmas about sums are proved by the same induction as lemmas about `+`."
hints:
  - text: "**Case split** on `n`, the number of terms. What is `sumTo (λ _ → zero) zero`?"
  - text: "In the `suc n` clause the goal is `sumTo (λ _ → 0) n ≡ 0`: the last term is `zero`, and `_+ zero` computes away. That leaves exactly the statement for the smaller `n`."
  - text: "`sumTo-zero zero = refl`, and `sumTo-zero (suc n) = sumTo-zero n`."
---
Finite sums turn up everywhere in real mathematics, and proof libraries spend a lot
of effort on lemmas about them: splitting a sum, reindexing it, pulling a term out.
Those lemmas all look like this level.

`sumTo f n` adds up `f 0 + f 1 + … + f (n - 1)`:

```agda
sumTo f zero    = zero
sumTo f (suc n) = sumTo f n + f n
```

Read the type, `(ℕ → ℕ) → ℕ → ℕ`. Its first argument is itself a function, which
says what each term of the sum is. This is the first time you've passed a function
to one of your own definitions.

Prove that the sum of zeros is zero. The function `λ _ → zero` ignores its argument
and always returns `zero`, where `_` means "I don't need this name".

Although a `λ` appears in the statement, nothing about the proof has changed.
Induct on the number that recursion looks at, and read each **Goal**.

<!-- @conclusion -->
A sum is a fold, and a lemma about a sum is an induction on its length. When you
read lemmas about sums in real code, look for this shape.

**Addition World complete.**
