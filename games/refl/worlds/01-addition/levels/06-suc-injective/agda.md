---
example_explanation: |-
  1. Define a predecessor function by cases.
  2. Apply it twice to both endpoints using `cong`.
  3. The constructors disappear by computation. The exercise removes only one successor.
hints:
- hidden: false
  text: Equal constructor values have equal payloads.
- hidden: true
  text: The supplied `pred` removes a successor. Apply it to both sides of the hypothesis.
- hidden: true
  text: Use `cong … h` with a function that undoes the constructor.
learning_goals:
- Constructors are injective, and `cong` with a *destructor* proves it.
- 'Pattern matching on `refl` also works: `suc-injective refl = refl`.'
title: suc is injective
---
Equal constructor values have equal payloads.

From `suc x ≡ suc y` conclude `x ≡ y`. Two ways: apply the predecessor
function to both sides (`cong pred`), or pattern match on the equality
proof itself — writing `refl` on the left of `=` tells Agda the two sides
unify, which makes `x` and `y` the same variable.


<!-- @conclusion -->

Injectivity of constructors is something Agda's unifier knows; the case
split on `refl` is the first taste of *dependent* pattern matching, World
4's subject.
