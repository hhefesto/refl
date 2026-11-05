# Addition 1: suc-+

About 45 s. Agda.

Statement: `suc-+ : ∀ (x y : ℕ) → suc x + y ≡ suc (x + y)`

**Open.** Welcome to Addition World. We know what `x + suc y` is, because that's the definition. Today: what's `suc x + y`?

1. **Do:** Case split on `y`.
   **Say:** Induct on `y`, because that's the argument addition computes on.

2. **Do:** Give `refl` in the `zero` clause.
   **Say:** Base case: both sides compute.

3. **Do:** Give `cong suc (suc-+ x y)` in the `suc` clause.
   **Say:** Same recipe as `zero-+`: `cong suc` of the recursive call.

**Close.** With `zero-+` and `suc-+` in the inventory, we've got what we need for commutativity.

**Finished proof:**

```agda
suc-+ x zero = refl
suc-+ x (suc y) = cong suc (suc-+ x y)
```
