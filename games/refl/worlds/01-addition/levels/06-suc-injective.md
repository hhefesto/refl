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
      bend2: "Addition.succ_inj"
      agda: "suc-injective"
      lean: "succ_inj"
      doc: "suc-injective.md"
hints:
  - text: "You want to go from `suc x ≡ suc y` to `x ≡ y`, which means taking a `suc` off both sides. Which function in the statement does that?"
  - text: "`pred (suc x)` computes to `x`. So apply `pred` to both sides of `h` with `cong`."
  - text: "`suc-injective h = cong pred h`."
---
From `suc x ≡ suc y` conclude `x ≡ y`. This says `suc` never sends two different
numbers to the same one, which is what **injective** means. It is true of every
constructor, and it is not automatic from anything you have proved so far.

All your lemmas so far have added things to both sides of an equation: `cong suc`
wraps a `suc` around each. This time you need to take one off. Remember that
`cong` works with *any* function, not only constructors.

The statement defines one such function:

```agda
pred : ℕ → ℕ
pred zero = zero
pred (suc n) = n
```

`pred` computes when it sees a `suc`. Press **Check** and **Goal** to see the
context. What would both sides of `h` turn into if you applied `pred` to them?

<!-- @conclusion -->
There is a second proof. **Case split** on `h` itself: Agda writes
`suc-injective refl = ?`, and now `x` and `y` are the same variable, because a
`refl` can only prove `suc x ≡ suc y` if they are. Then `refl` closes it.

Matching on an equation like that is your first taste of *dependent* pattern
matching, which is Equality World's subject.
