---
learning_goals:
  - "Not `A` is written `A -> Empty`, so a proof of it takes an `A`."
  - "Contraposition without classical logic."
hints:
  - text: "Press **Goal**. The goal is `Empty`. The only thing that can produce one is `nb`, and it needs a `B`. Where can you get one?"
  - text: "`f(a)` is a `B`."
  - text: "`nb(f(a))`."
example_explanation: |-
  1. A refutation of `A` is a function from `A` to `Empty`.
  2. The law gives you `a` and the alleged refutation `notA`.
  3. Apply one to the other. In the exercise, build the refuted value using the additional function hypothesis.
---
Negation isn't a new connective. "Not A" means: from a proof of `A`, I could produce a proof of `Empty`. So a proof of "not A" is a function `A -> Empty`, and *using* a negation means applying it. For equations, Bend has a shorthand: `{a != b : T}` is `{a == b : T} -> Empty`.

This statement is **contraposition**: if `A` implies `B`, then not-`B` implies not-`A`. It looks like it must be a difficult argument. But read the law. It has the two implications as hypotheses, plus an `a : A`, and the goal is `Empty`.

So you have two functions and a value in your context, and a goal of `Empty`. Follow the types: start from what you need and work backwards.

<!-- @conclusion -->
Constructively, "not not A implies A" is *not* provable in general, but "A implies not not A" and contraposition are. Bend's logic is constructive: a proof is a program, so it can't conjure an `A` out of the absence of a refutation.
