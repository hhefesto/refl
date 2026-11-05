---
id: subst
index: 8
title: "subst and transport"
learning_goals:
  - "`subst P p : P x → P y` transports along `p : x ≡ y`."
  - "Choosing the motive `P` is the whole game: `(x ≡_)`, `(_+ z ≡ w)`, …"
unlocks:
  lemmas:
    - name: "subst"
      agda: "subst"
      lean: "Eq.subst"
      doc: "subst.md"
forbids: ["trans"]
hints:
  - text: "You hold `p : x ≡ y` and want `x ≡ z`. Think of `p` as `P y`, and the goal as `P z`, for a `P` that leaves the `x ≡` alone and varies what comes after it. You move along `q : y ≡ z`."
  - text: "The motive is the section `(x ≡_)`, that is, `λ w → x ≡ w`. To name the implicit `x`, write it in braces on the left: `trans′ {x} p q = ?`."
  - text: "`trans′ {x} p q = subst (x ≡_) q p`."
---
If two things are equal, whatever is true of one is true of the other. That's `subst`:

```agda
subst : ∀ {A : Set} (P : A → Set) {x y : A} → x ≡ y → P x → P y
```

`P` is a predicate, and it's called the **motive**: it says what's being carried across the equation. Given a
proof that `x ≡ y`, and a proof of `P x`, `subst` hands you a proof of `P y`. Agda can't guess `P` from the types,
because many different predicates could fit, so you have to tell it.

Picking `P` is the whole art of using `subst`. Here's a way to do it: write down the type you have and the type
you want, and find what's the same in both. For example, to go from `a + 1 ≡ 5` to `b + 1 ≡ 5` along `a ≡ b`,
what stays the same is "`_ + 1 ≡ 5`", so `P` is `λ n → n + 1 ≡ 5`.

Now reprove `trans` this way, without pattern matching and without using `trans`, which is forbidden here. You have
`p : x ≡ y` and `q : y ≡ z`, and you owe `x ≡ z`. What stays the same, and which equation moves you?

Your motive will need to mention `x`, which isn't in scope because it's implicit. To name it, write `{x}` on the
left of `=`, as in `trans′ {x} p q = ?`.

<!-- @conclusion -->
A motive doesn't have to be about one equation. The standard library's `subst₂` carries a predicate across two
equations at once, and the motive is the same kind of thinking. Most of the skill is in seeing what stays fixed.
