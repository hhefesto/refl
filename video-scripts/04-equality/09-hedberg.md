# Equality 9: Hedberg: decidable equality gives UIP

About 1 min 00 s. Agda.

Statement: `≡-irrelevant : ∀ {x y : ℕ} (p q : x ≡ y) → p ≡ q`

**Open.** Are two proofs of the same equation always equal? Without axiom K, you don't get that for free. For natural numbers, you can prove it.

1. **Do:** Point at `canon` and `canon-const`.
   **Say:** The plan: send every proof through decidable equality. The result doesn't depend on which proof went in.

2. **Do:** Give `trans-symˡ refl = refl`, then `canon-inv refl = trans-symˡ (canon refl)`.
   **Say:** Two small helpers. The round trip through `canon` gets you back where you started.

3. **Do:** Fill the middle step: `cong (trans (sym (canon refl))) (canon-const p q)`.
   **Say:** `canon p` and `canon q` are the same, so swap one for the other.

**Close.** That's Hedberg's theorem, and the standard library packages it. Now you can read `Decidable⇒UIP` in real code and know what it's doing.

**Finished proof:**

```agda
trans-symˡ refl = refl

canon-inv refl = trans-symˡ (canon refl)

≡-irrelevant p q =
  begin
    p                                    ≡⟨ sym (canon-inv p) ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ cong (trans (sym (canon refl))) (canon-const p q) ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ canon-inv q ⟩
    q                                    ∎
```
