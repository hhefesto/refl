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
*yes*. Most of the time the last thing you type is `refl`: "these two things
are the same, and the checker can see it".

The game starts from nothing (its own natural numbers, its own equality) and
ends where the real code lives: Conal Elliott's `felix` library, the ICFP 2021
language-derivatives development, and the specifications in `formalTransformer`
and `aanalyzer-classic`. Pick a language in the top-right corner — Agda first;
Lean 4 is available for the early worlds, Bend2 will appear when it ships.

Click a world on the map to begin. Solved levels unlock lemmas, commands and
syntax into your **Inventory**.
