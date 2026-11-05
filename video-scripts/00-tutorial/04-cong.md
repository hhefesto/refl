# Tutorial 4: cong

About 1 min 00 s. Agda.

Statement: `suc-cong : ∀ {x y : ℕ} → x ≡ y → suc x ≡ suc y`

**Open.** Time for the first real tool. If two numbers are equal, their successors are equal. Obvious, but how do you say it?

1. **Do:** Point at `h` in the template.
   **Say:** An implication is a function too, so the hypothesis is just an argument. Here it's called `h`.

2. **Do:** Point at the braces.
   **Say:** The curly braces make `x` and `y` implicit. Agda works them out from `h`, so I don't write them.

3. **Do:** Open the inventory and show `cong`.
   **Say:** `cong` says: if `x ≡ y`, then `f x ≡ f y`. First the function, last the equation.

4. **Do:** Give `cong suc h`.
   **Say:** Apply `suc` to both sides of `h`. Done.

**Close.** `cong suc` of something is going to be in nearly every inductive step you write in this game.

**Finished proof:**

```agda
suc-cong h = cong suc h
```
