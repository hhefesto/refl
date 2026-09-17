```agda
open ≡-Reasoning

proof =
  begin
    a ≡⟨ p ⟩      -- p : a ≡ b
    b ≡⟨⟩         -- by computation
    b' ≡⟨ q ⟩     -- q : b' ≡ c
    c ∎
```
`begin_`, `_≡⟨_⟩_`, `_≡⟨⟩_` and `_∎` are ordinary functions defined with `trans` (see `Refl.Eq`); the standard library's `Relation.Binary.PropositionalEquality` exports the same names, and `Relation.Binary.Reasoning.Setoid` the `≈⟨ ⟩` version felix uses. Lean: `calc`.
