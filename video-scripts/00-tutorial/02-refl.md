# Tutorial 2: Let the checker walk

About 1 min 00 s. Agda.

Statement: `two-plus-two : 2 + 2 ≡ 4`

**Open.** Same statement as last time. That whole chain from the last video? It's going to become one word.

1. **Do:** Press Check and point at the hole's type.
   **Say:** As written, the goal says `2 + 2 ≡ 4`.

2. **Do:** Select the hole and press Goal.
   **Say:** Goal shows the same type after computing: `4 ≡ 4`. The checker just took the walk we did by hand.

3. **Do:** Give `refl`.
   **Say:** Equality has one constructor, `refl`, and it only proves that a thing equals itself. Four equals four, so that's the proof.

**Close.** Written the same isn't the test. Computing to the same term is. And that's also the limit: `refl` won't prove `zero + x ≡ x`, because that gets stuck on the variable.

**Finished proof:**

```agda
two-plus-two = refl
```
