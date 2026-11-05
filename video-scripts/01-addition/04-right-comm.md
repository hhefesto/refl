# Addition 4: +-right-comm

About 1 min 00 s. Agda.

Statement: `+-right-comm : ∀ (x y z : ℕ) → (x + y) + z ≡ (x + z) + y`

**Open.** Here's the readable notation I promised. The template already lays out the chain. We just justify each step.

1. **Do:** Point at the `begin … ∎` block.
   **Say:** Same notation as the very first level, except now each bracket holds a real lemma.

2. **Do:** Fill step one: `+-assoc x y z`.
   **Say:** Regroup to the right.

3. **Do:** Fill step two: `cong (x +_) (+-comm y z)`.
   **Say:** Swap `y` and `z` underneath `x +`. `(x +_)` is a section: `x +` waiting for its other argument.

4. **Do:** Fill step three: `sym (+-assoc x z y)`.
   **Say:** And regroup back.

**Close.** Plan the terms first, then fill in the reasons. From now on, anything longer than one `trans` should look like this.

**Finished proof:**

```agda
+-right-comm x y z =
  begin
    (x + y) + z ≡⟨ +-assoc x y z ⟩
    x + (y + z) ≡⟨ cong (x +_) (+-comm y z) ⟩
    x + (z + y) ≡⟨ sym (+-assoc x z y) ⟩
    (x + z) + y ∎
```
