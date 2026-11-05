```agda
_≟_ : (m n : ℕ) → Dec (m ≡ n)
```
`yes p` with a proof or `no ¬p` with a refutation. `with i ≟ j` is how you write a function that behaves differently when two numbers are equal, such as the Kronecker delta.
