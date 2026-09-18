---
id: tutorial
title: "Tutorial World"
dependencies: []
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
Eight levels introduce equality by computation, substitution, induction and
composition of proofs. Each lesson explains the syntax and commands for your
selected language, with clues and a checked example available from the start.

The world uses natural numbers built from zero and successor. Addition recurses
on its **second** argument: adding a known numeral computes even when the first
argument is a variable. Adding an unknown number to zero instead needs a proof
by induction. Equality is a type, and a proof is a program inhabiting that type.
