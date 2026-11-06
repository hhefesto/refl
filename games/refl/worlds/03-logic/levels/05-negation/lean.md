---
learning_goals:
  - "`¬ A` unfolds to `A → False`, so a proof of `¬ A` takes an `A`."
  - "Contraposition without classical logic."
hints:
  - text: "The goal is `¬B → ¬A`. `intro nb a` takes both hypotheses, because `intro` knows `¬A` is a function to `False`."
  - text: "The goal is now `False`. The only thing that can produce one is `nb`, and it needs a `B`. Where can you get one?"
  - text: "`exact nb (f a)`."
example_explanation: |-
  1. Unfold double negation to `(A → False) → False`.
  2. Introduce the alleged refutation `notA`.
  3. Apply it to the given `a`. In the exercise, build the refuted value using the additional function hypothesis.
---
Negation isn't a new connective. It's defined in terms of the ones you have:

```lean
def Not (a : Prop) : Prop := a → False
```

"Not A" means: from a proof of `A`, I could produce a proof of `False`. So a proof of `¬ A` is a function, and *using* a
negation means applying it. Type `¬` as `\neg`.

This statement is **contraposition**: if `A` implies `B`, then not-`B` implies not-`A`. It looks like it must be a difficult
argument, but it's really a function type with two arguments, ending in `False`. **Goal** shows `¬B → ¬A`, but `intro` will
see through the `¬`.

So introduce both arguments. You'll then have two functions and a value above the line, and a goal of `False`. Follow the types:
start from what you need and work backwards.

<!-- @conclusion -->
Constructively, `¬ ¬ A → A` is *not* provable without an extra axiom, but `A → ¬ ¬ A` and contraposition are. In Lean you can
ask for the classical axiom when you want it, but the proof you've just written doesn't need it.
