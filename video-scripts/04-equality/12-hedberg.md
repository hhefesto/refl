# Equality 12: Hedberg: decidable equality gives UIP

About 1 min 15 s. Agda.

Statement: `≡-irrelevant : ∀ {x y : ℕ} (p q : x ≡ y) → p ≡ q`

**Open.** Are two proofs of the same equation always equal? Without axiom K, you don't get that for free. For natural numbers, you can prove it, and we've done the hard part already.

1. **Do:** Point at the chain in the template.
   **Say:** The plan has three steps. Rebuild `p` from `canon p`. Swap `canon p` for `canon q`. And what's left is `q` rebuilt from `canon q`.

2. **Do:** Give `sym (canon-inv p)` in the first hole.
   **Say:** That's `canon-inv`, pointing the other way.

3. **Do:** Give `cong (trans (sym (canon refl))) (canon-const p q)` in the second hole.
   **Say:** `canon p` and `canon q` are the same, so swap one for the other, under the `trans`.

4. **Do:** Give `canon-inv q` in the third hole.
   **Say:** And we're at `q`.

**Close.** That's Hedberg's theorem, and the standard library packages it. Now you can read `Decidable⇒UIP` in real code and know what it's doing.

**Finished proof:**

```agda
≡-irrelevant p q =
  begin
    p                                    ≡⟨ sym (canon-inv p) ⟩
    trans (sym (canon refl)) (canon p)   ≡⟨ cong (trans (sym (canon refl))) (canon-const p q) ⟩
    trans (sym (canon refl)) (canon q)   ≡⟨ canon-inv q ⟩
    q                                    ∎
```
