# Addition 2: +-comm

About 1 min 00 s. Agda.

Statement: `+-comm : ∀ (x y : ℕ) → x + y ≡ y + x`

**Open.** Commutativity. x plus y is y plus x. Everybody knows it. Almost nobody has proved it.

1. **Do:** Case split on `y`, then press Goal in the `zero` clause.
   **Say:** The goal computes to `x ≡ zero + x`. That's `zero-+`, pointing the wrong way.

2. **Do:** Give `sym (zero-+ x)`.
   **Say:** So flip it.

3. **Do:** Press Goal in the `suc` clause.
   **Say:** The left side computes to `suc (x + y)`. The right side is `suc y + x`, which is exactly what `suc-+` talks about.

4. **Do:** Give `trans (cong suc (+-comm x y)) (sym (suc-+ y x))`.
   **Say:** Use the induction hypothesis under `suc`, then flip `suc-+`.

**Close.** That's correct and also pretty hard to read. Two levels from now we'll write this kind of thing properly.

**Finished proof:**

```agda
+-comm x zero = sym (zero-+ x)
+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))
```
