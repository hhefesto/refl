# Equality 8: subst and transport

About 1 min 00 s. Agda.

Statement: `trans′ : ∀ {x y z : ℕ} → x ≡ y → y ≡ z → x ≡ z`

**Open.** `subst` moves a proof along an equation. The whole trick is telling it what you're moving through.

1. **Do:** Show `subst` in the inventory.
   **Say:** `subst P p` takes a proof of `P x` to a proof of `P y`. `P` is called the motive.

2. **Do:** Add `{x}` to the left-hand side.
   **Say:** I need to mention `x`, so I bring the implicit argument into scope.

3. **Do:** Give `subst (x ≡_) q p`.
   **Say:** The motive is `x ≡ something`. `p` proves it at `y`, and `q` moves it over to `z`.

**Close.** Choosing the motive is the entire game. `trans` itself is banned here, and we rebuilt it anyway.

**Finished proof:**

```agda
trans′ {x} p q = subst (x ≡_) q p
```
