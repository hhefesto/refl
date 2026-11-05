# Logic 2: And is a pair

About 30 s. Agda.

Statement: `×-comm : ∀ {A B : Set} → A × B → B × A`

**Open.** And is a pair. To prove A and B, you hand over both proofs.

1. **Do:** Case split on `p`, then rename the two parts to `a` and `b`.
   **Say:** The pattern is a pair. Agda picks its own names for the parts, so I rename them.

2. **Do:** Give `b , a`.
   **Say:** Swap them.

**Close.** That's a program that swaps a pair, and also the proof that "and" is commutative. Same thing.

**Finished proof:**

```agda
×-comm (a , b) = b , a
```
