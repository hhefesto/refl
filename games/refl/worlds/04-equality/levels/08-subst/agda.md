---
example_explanation: |-
  1. Choose the family `λ n → n + 1 ≡ 5`.
  2. The hypothesis is an inhabitant of this family at `a`.
  3. Transport it along `p` to the family at `b`. In the exercise choose a family that varies the right endpoint of an equality.
hints:
- hidden: false
  text: Transport moves evidence through a family of types along an equality.
- hidden: true
  text: The family should keep the left endpoint fixed and vary the right endpoint.
    Transport the first proof along the second.
- hidden: true
  text: Use `subst (λ w → … ≡ w) q p`, bringing the implicit left endpoint into scope
    if needed.
learning_goals:
- '`subst P p : P x → P y` transports along `p : x ≡ y`.'
- 'Choosing the motive `P` is the whole game: `(x ≡_)`, `(_+ z ≡ w)`, …'
title: subst and transport
---
Transport moves evidence through a family of types along an equality.

`subst P p` moves a proof of `P x` to a proof of `P y`. The art is
picking `P` (the *motive*), usually as a section. Reprove `trans` with
`subst` instead of pattern matching — `trans` itself is forbidden here.


<!-- @conclusion -->

`subst₂` (two equations at once) is what `blocks-ext` in `Block.lagda:93`
uses to transport across two index equations; the motive there is
`(λ x y → M x y ≡ N x y)`.
