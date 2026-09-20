---
title: "The Refl Game"
worlds:
  - tutorial
  - addition
  - multiplication
  - logic
  - equality
  - order
  - lists
  - universes
  - records
  - modules
  - stdlib
  - matrices
  - coinduction
  - languages
  - instances
  - setoids
  - categories
  - ad
  - tours
---
Welcome. This is a game about **proofs as programs**. Every level is a
statement with a hole in it; you fill the hole until the type checker says
*yes*. A proof by reflexivity says: "these two things compute to the same
value, and the checker can see it". Each language spells that proof differently.

The game starts from nothing (its own natural numbers, its own equality) and
ends where the real code lives: Conal Elliott's
[`felix`](https://github.com/conal/felix) library, the [ICFP 2021
language-derivatives development](https://github.com/conal/paper-2021-language-derivatives),
and the specifications in [`ana`](https://github.com/hhefesto/ana) and
[Spectra](https://xpsoasis.org). Pick a language in the top-right corner — Agda
first; Lean 4 and Bend 2 are available throughout Tutorial World.

Click a world on the map to begin. Solved levels unlock lemmas, commands and
syntax into your **Inventory**.

You will spend this game learning to write proofs, but the proofs are not the
lesson. The lesson is reading and writing *types* — the propositions
themselves. I believe the future of programming is asking good questions, good
types, and letting the computer go find an answer; and nobody asks a good
question without first knowing how an answer works. That is what the proofs
here are for.
