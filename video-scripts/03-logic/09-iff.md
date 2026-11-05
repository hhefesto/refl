# Logic 9: If and only if

About 30 s. Agda.

Statement: `×-swap-⇔ : ∀ {A B : Set} → (A × B) ⇔ (B × A)`

**Open.** If and only if is two implications packaged together. And we've already written one of them.

1. **Do:** Show `mk⇔` in the inventory.
   **Say:** `mk⇔` takes one function each way.

2. **Do:** Give `mk⇔ ×-comm ×-comm`.
   **Say:** Swapping a pair is its own way back, so the same lemma fills both slots.

**Close.** The standard library has this same `mk⇔`, so you'll recognize it in real code.

**Finished proof:**

```agda
×-swap-⇔ = mk⇔ ×-comm ×-comm
```
