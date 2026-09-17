---
id: suc-injective
index: 6
title: "suc is injective"
learning_goals:
  - "Constructors are injective, and `cong` with a *destructor* proves it."
  - "Pattern matching on `refl` also works: `suc-injective refl = refl`."
unlocks:
  lemmas:
    - name: "suc-injective"
      agda: "suc-injective"
      lean: "succ_inj"
      doc: "suc-injective.md"
hints:
  - text: "`pred` is defined in the statement: `pred (suc n) = n`. Apply it to both sides of the hypothesis with `cong`."
  - text: "`suc-injective h = cong pred h`. (Agda also accepts `suc-injective refl = refl`: matching `h` against `refl` forces `x` and `y` to be the same.)"
    hidden: true
---
From `suc x ≡ suc y` conclude `x ≡ y`. Two ways: apply the predecessor
function to both sides (`cong pred`), or pattern match on the equality
proof itself — writing `refl` on the left of `=` tells Agda the two sides
unify, which makes `x` and `y` the same variable.

<!-- @conclusion -->
Injectivity of constructors is something Agda's unifier knows; the case
split on `refl` is the first taste of *dependent* pattern matching, World
4's subject.
