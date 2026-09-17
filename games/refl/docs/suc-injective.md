```agda
suc-injective : ∀ {x y : ℕ} → suc x ≡ suc y → x ≡ y
```
Either `cong pred h` or `suc-injective refl = refl` (matching the proof forces `x` and `y` to unify). Lean: `succ_inj` / `Nat.succ.inj`.
