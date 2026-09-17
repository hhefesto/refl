---
id: logic
title: "Logic World"
dependencies: [tutorial]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Propositions are types; proofs are programs. This world walks through the
dictionary:

| Logic | Type | Proof is… |
|---|---|---|
| A implies B | `A → B` | a function |
| A and B | `A × B` | a pair `a , b` |
| A or B | `A ⊎ B` | `inj₁ a` or `inj₂ b` |
| true | `⊤` | `tt` |
| false | `⊥` | nothing — and `()` refutes |
| not A | `¬ A = A → ⊥` | a function to nowhere |
| for all x, P x | `(x : A) → P x` | a dependent function |
| exists x, P x | `Σ A P`, `∃ P` | a witness and a proof |
| decidable | `Dec A` | `yes a` or `no ¬a` |

Everything is defined in `Refl.Logic`; open the inventory to read the
definitions. This is exactly the setting of *Symbolic and Automatic
Differentiation of Languages*: a language is a predicate on strings, union is
`⊎`, intersection is `×`, and a proof of membership is a parse.
