---
id: absurd
index: 4
title: "From falsity, anything"
learning_goals:
  - "`⊥` has no constructors; case splitting on it yields the absurd clause `()`."
  - "`⊤` has exactly one proof, `tt`."
unlocks:
  syntax:
    - name: "()"
      doc: "absurd.md"
hints:
  - text: "Case split on the `⊥` argument: Agda writes `ex-falso ()` — a clause with no right-hand side, because there is no case."
  - text: "For the second lemma, give `tt`, or let Refine find it."
    hidden: true
---
Two lemmas. `ex-falso : ⊥ → A`: case split on the hypothesis of type `⊥`;
since `⊥` has no constructors Agda produces the **absurd pattern** `()`
and the clause needs no right-hand side.

`trivial : ⊤`: the one proof is `tt`.

<!-- @conclusion -->
`⊥-elim` in `Refl.Logic` is exactly `ex-falso`. You will use it whenever a
hypothesis is impossible: `⊥-elim (¬p refl)`.
