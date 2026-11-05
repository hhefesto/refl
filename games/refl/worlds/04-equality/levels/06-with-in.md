---
id: with-in
index: 6
title: "with … in eq"
learning_goals:
  - "`with e in eq` also remembers `eq : e ≡ result` in each branch."
  - "Boolean tests must be remembered to be reasoned about."
unlocks:
  syntax:
    - name: "with … in eq"
      doc: "with-in.md"
hints:
  - text: "`f n` is stuck on `n ≡ᵇ 0`, so write `f-nonzero n h with n ≡ᵇ 0 in eq` and two clauses, `... | true = ?` and `... | false = ?`. The `in eq` is what keeps the fact you'll need."
  - text: "In the `true` clause the goal is `1 ≡ n`, which is false, and `eq : (n ≡ᵇ 0) ≡ true`. `≡ᵇ⇒≡ n 0 eq` turns that into `n ≡ 0`, which `h` refutes. So this case is impossible."
  - text: "`... | true = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))`, and `... | false = refl`."
---
Last level, you matched on a `Dec`, which carries its evidence inside. A test that returns a boolean
doesn't: a plain `true` can't tell you why it's true. If you match on it, you learn which branch you're
in, but you've no way to use that fact in a proof.

`with e in eq` solves this. It matches on `e` as before, and in each branch it also gives you an equation
`eq` saying what `e` turned out to be.

```agda
f : ℕ → ℕ
f n with n ≡ᵇ 0
... | true  = 1
... | false = n
```

`_≡ᵇ_` is an equality test that returns a `Bool`. Prove that `f n ≡ n` whenever `n` isn't zero.

Write the `with` as you did last level, adding `in eq`, and give it one clause each for `true` and `false`.
Then ask for the **Goal** and read the context in each. In the `false` clause you should see that `f` has
computed to `n`. In the `true` clause you're in an impossible case: `n` isn't zero, yet the test says it is.

To turn the test's result into a real equation, `Refl.Bool` gives you this lemma:

```agda
≡ᵇ⇒≡ : ∀ m n → (m ≡ᵇ n) ≡ true → m ≡ n
```

<!-- @conclusion -->
You'll see `with … in` wherever code branches on a boolean test and a proof has to follow it. A `with` can
also take several expressions at once, separated by `|`, as the last level of this world shows.
