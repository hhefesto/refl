# Logic 5: Negation is a function to ⊥

About 1 min 00 s. Agda.

Statement: `contraposition : ∀ {A B : Set} → (A → B) → ¬ B → ¬ A`

**Open.** What's "not A"? In Agda it's defined as: A implies false. So a proof of a negation is a function.

1. **Do:** Unfold the goal out loud.
   **Say:** `¬ B → ¬ A` is really `(B → ⊥) → A → ⊥`. Two more arguments I haven't named yet.

2. **Do:** Edit the clause to `contraposition f ¬b a = ?` and press Check.
   **Say:** Name them on the left. Now I've got `f`, `¬b` and `a`, and I need a `⊥`.

3. **Do:** Give `¬b (f a)`.
   **Say:** `f a` gives me a `B`, and `¬b` turns a `B` into `⊥`.

**Close.** Double negation elimination isn't provable here, because Agda is constructive: a proof is a program, and a program can't conjure an `A` out of thin air.

**Finished proof:**

```agda
contraposition f ¬b a = ¬b (f a)
```
