---
id: logic
title: "Logic World"
dependencies: [tutorial]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Propositions are types; proofs are programs. This world walks through the dictionary:

| Logic | Agda | Lean | Bend | Proof is… |
|---|---|---|---|---|
| A implies B | `A → B` | `A → B` | `A -> B` | a function |
| A and B | `A × B` | `A ∧ B` | `A & B` | a pair |
| A or B | `A ⊎ B` | `A ∨ B` | `Either<A, B>` | one side, tagged |
| true | `⊤` | `True` | `Unit` | one trivial proof |
| false | `⊥` | `False` | `Empty` | nothing: no proof exists |
| not A | `¬ A` | `¬ A` | `A -> Empty` | a function to nowhere |
| for all x, P x | `(x : A) → P x` | `∀ x, P x` | `@x:A -> P(x)` | a dependent function |
| exists x, P x | `∃ P` | `∃ x, P x` | `exs x: A` | a witness and a proof |
| decidable | `Dec A` | `Decidable A` | `Refl.Dec<A>` | yes or no, with evidence |

Each level shows the definitions it needs. The last one uses this dictionary the way research papers
do: a language is a predicate on strings, union is *or*, intersection is *and*, and a proof of
membership is a parse.
