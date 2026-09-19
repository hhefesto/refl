---
title: "with … in eq"
learning_goals:
  - "`with e in eq` also remembers `eq : e ≡ result` in each branch."
  - "Boolean tests must be remembered to be reasoned about."
hints:
  - text: "`f n` is stuck on `n ≡ᵇ 0`. Abstract it *and keep the equation*: `f-nonzero n h with n ≡ᵇ 0 in eq`."
  - text: "`true` branch: `eq : (n ≡ᵇ 0) ≡ true`, so `≡ᵇ⇒≡ n 0 eq : n ≡ 0` contradicts `h`. `false` branch: `refl`."
    hidden: true
example_explanation: |-
  1. Abstract the Boolean test.
  2. `in eq` keeps evidence relating the original expression to the selected Boolean.
  3. In the true branch, reflection contradicts `notZero`; in the false branch use `refl`. In the exercise the target also mentions a function defined by the test. Use the saved equation to turn a Boolean success into a propositional equality.
---
Sometimes matching on the result of a test is not enough: you also need
to know *that the test returned that result*. `with e in eq` binds
`eq : e ≡ ⟨pattern⟩` in each branch.

```agda
f : ℕ → ℕ
f n with n ≡ᵇ 0
... | true  = 1
... | false = n
```

Prove `n ≢ 0 → f n ≡ n`. In the `true` branch you must derive a
contradiction from `n ≡ᵇ 0` being `true`; `≡ᵇ⇒≡` from `Refl.Bool` turns
that into `n ≡ 0`.

<!-- @conclusion -->
`Block.lagda:70` (`with splitAt a k in eq`) and `Decoding.agda:151` use
exactly this, the latter with two scrutinees at once: `with ⊔-sel x (maxW
xs) | t ≤ᵇ den * x in kept`.
