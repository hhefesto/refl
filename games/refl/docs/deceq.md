```agda
_≟_ : (m n : ℕ) → Dec (m ≡ n)
```
`yes p` with a proof or `no ¬p` with a refutation. `with i ≟ j` is how Spectra2's Kronecker delta and the language paper's `_◃_` transports are written. Lean: `decEq` / `if h : m = n then … else …`.
