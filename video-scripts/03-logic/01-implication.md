# Logic 1: Implication is a function

About 1 min 00 s. Agda.

Statement: `modus-ponens : ∀ {A B : Set} → A → (A → B) → B`

**Open.** Logic World. The big idea: propositions are types, and proofs are programs. So what's a proof of an implication? A function.

1. **Do:** Read the statement.
   **Say:** Given `A`, and given `A` implies `B`, conclude `B`. That's modus ponens, the oldest rule there is.

2. **Do:** Edit the clause to `modus-ponens a f = ?` and press Check.
   **Say:** Name the two arguments on the left. Refine with an empty box would do this too, as `λ x x₁ → ?`, with names Agda makes up.

3. **Do:** Give `f a`.
   **Say:** Apply the function to the argument. That's the whole proof.

**Close.** `A` and `B` could be anything, so the only possible proof is the one that uses the hypotheses. That's the sense in which this is logic.

**Finished proof:**

```agda
modus-ponens a f = f a
```
