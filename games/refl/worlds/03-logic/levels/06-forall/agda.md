---
example_explanation: |-
  1. Introduce the two dependent functions and an index.
  2. Apply both functions at that same index.
  3. Pair their results. The exercise runs this construction backwards, extracting a function for each projection.
hints:
- hidden: false
  text: A universally quantified proof is a function whose result type depends on
    its input.
- hidden: true
  text: The target is a pair of functions. Each function calls `h` at its own argument,
    then projects.
- hidden: true
  text: Use `(λ n → …) , (λ n → …)`.
learning_goals:
- A universal statement `∀ n → P n` is a dependent function.
- Predicates are functions into `Set`.
title: For all
---
A universally quantified proof is a function whose result type depends on its input.

`P Q : ℕ → Set` are **predicates**: functions from numbers to types. A
proof of `∀ n → P n × Q n` is a function producing pairs; split it into two
functions.


<!-- @conclusion -->

`ℕ → Set` is the type of predicates on `ℕ`; `A✶ → Set` is the type of
languages over `A` in the ICFP 2021 paper. Same idea, and this lemma is
the distributivity of `∀` over `∩`.
