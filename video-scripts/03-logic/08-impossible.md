# Logic 8: Impossible equations

About 1 min 00 s. Agda.

Statement: `zero≢suc : ∀ (n : ℕ) → zero ≢ suc n`

**Open.** We can prove things are equal. How do you prove two things are different?

1. **Do:** Select the hole and press Goal.
   **Say:** `zero ≢ suc n` unfolds to `0 ≡ suc n → ⊥`. So I owe a function, and its argument would be a proof that zero is a successor.

2. **Do:** Show the definition of `_≡_` from the Tutorial.
   **Say:** The only way to make an equation is `refl`, and it only fits when both sides compute to the same thing. `zero` and `suc n` never will. So that argument can't exist.

3. **Do:** Give `λ ()`.
   **Say:** `λ ()` is a function with no body, because its argument can't exist. Agda checks that for me.

**Close.** Every proof that two constructors differ looks like this. Next level, we put it to use.

**Finished proof:**

```agda
zero≢suc n = λ ()
```
