# Addition 5: +-swap

About 45 s. Agda.

Statement: `+-swap : ∀ (x y z : ℕ) → x + (y + z) ≡ y + (x + z)`

**Open.** Same tools, but this time no skeleton. I write the whole chain myself.

1. **Do:** Type `begin`, then the first term `x + (y + z)` and the last term `y + (x + z) ∎`.
   **Say:** Start with the two ends.

2. **Do:** Add `(x + y) + z` with `sym (+-assoc x y z)`.
   **Say:** Regroup so `x` and `y` sit together.

3. **Do:** Add `(y + x) + z` with `cong (_+ z) (+-comm x y)`.
   **Say:** Swap them under `+ z`.

4. **Do:** Close with `+-assoc y x z`, then press Check.
   **Say:** A wrong middle term gives an error right at that step, which is the reason to write them down.

**Close.** With these rearrangement lemmas you can move terms anywhere in a sum. Multiplication World uses them constantly.

**Finished proof:**

```agda
+-swap x y z =
  begin
    x + (y + z) ≡⟨ sym (+-assoc x y z) ⟩
    (x + y) + z ≡⟨ cong (_+ z) (+-comm x y) ⟩
    (y + x) + z ≡⟨ +-assoc y x z ⟩
    y + (x + z) ∎
```
