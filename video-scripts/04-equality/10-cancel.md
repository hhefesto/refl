# Equality 10: Equations between proofs

About 1 min 00 s. Agda.

Statement: `trans-symˡ : ∀ {A : Set} {x y : A} (e : x ≡ y) → trans (sym e) e ≡ refl`

**Open.** A proof of an equation is a value. So you can ask whether two proofs are equal. Are they always? It's less obvious than it sounds, and it takes us three levels to answer.

1. **Do:** Read the statement.
   **Say:** Going along `e` backwards and then forwards gets you nowhere. This is an equation between proofs.

2. **Do:** Case split on `e`, then press Check and Goal.
   **Say:** The ends of `e` are separate variables, so I can match on it. Everything computes, and the goal is `refl ≡ refl`.

3. **Do:** Give `refl`.
   **Say:** A proof and its inverse cancel, just like in a group.

**Close.** Next level, we use this to rebuild any proof from a canonical one.

**Finished proof:**

```agda
trans-symˡ refl = refl
```
