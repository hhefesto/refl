# Tutorial 9: Reading: analog₁ (Timely Computation)

About 1 min 00 s. Agda.

Statement: `analog-same : ∀ δ h x̃ t → analog₁ δ h x̃ t ≡ analog₁′ δ h x̃ t`

**Open.** Every world ends with a reading level: a real definition from real code, with a piece removed. This one's from Timely Computation, ICFP 2023.

1. **Do:** Point at `analog₁`.
   **Say:** An analog gate takes a delay, a function, and an input signal, and gives you back a signal. Its type ends in a function.

2. **Do:** Fill the first hole: `h (x̃ (t + δ))`.
   **Say:** An arrow associates to the right, so I can take `t` as one more argument on the left instead of writing a lambda.

3. **Do:** Fill the second hole with `refl`.
   **Say:** And the two versions are equal by `refl`, because they compute to the same thing.

**Close.** Those two spellings look different in a paper, and now you've proved they're the same. That's Tutorial World. Addition is next.

**Finished proof:**

```agda
analog₁′ δ h x̃ t = h (x̃ (t + δ))

analog-same δ h x̃ t = refl
```
