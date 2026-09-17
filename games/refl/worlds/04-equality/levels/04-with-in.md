---
id: with-in
index: 4
title: "with … in eq"
learning_goals:
  - "`with e in eq` also remembers `eq : e ≡ result` in each branch."
  - "Boolean tests must be remembered to be reasoned about."
unlocks:
  syntax:
    - name: "with … in eq"
      doc: "with-in.md"
hints:
  - text: "`f n` is stuck on `n ≡ᵇ 0`. Abstract it *and keep the equation*: `f-nonzero n h with n ≡ᵇ 0 in eq`."
  - text: "`true` branch: `eq : (n ≡ᵇ 0) ≡ true`, so `≡ᵇ⇒≡ n 0 eq : n ≡ 0` contradicts `h`. `false` branch: `refl`."
    hidden: true
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
