---
title: "suc is injective"
learning_goals:
  - "Constructors are injective, and `cong` with a *destructor* proves it."
  - "Pattern matching on `refl` also works: `suc-injective refl = refl`."
hints:
  - text: "`pred` is defined in the statement: `pred (suc n) = n`. Apply it to both sides of the hypothesis with `cong`."
  - text: "`suc-injective h = cong pred h`. (Agda also accepts `suc-injective refl = refl`: matching `h` against `refl` forces `x` and `y` to be the same.)"
    hidden: true
example_explanation: |-
  1. Define a predecessor function by cases.
  2. Apply it twice to both endpoints using `cong`.
  3. The constructors disappear by computation. The exercise removes only one successor.
---
From `suc x ≡ suc y` conclude `x ≡ y`. Two ways: apply the predecessor
function to both sides (`cong pred`), or pattern match on the equality
proof itself — writing `refl` on the left of `=` tells Agda the two sides
unify, which makes `x` and `y` the same variable.

<!-- @conclusion -->
Injectivity of constructors is something Agda's unifier knows; the case
split on `refl` is the first taste of *dependent* pattern matching, World
4's subject.
