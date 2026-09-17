```agda
cong : ∀ {A B : Set} (f : A → B) {x y : A} → x ≡ y → f x ≡ f y
```

Apply a function to both sides of an equation. The typical inductive step is `cong suc (ih)`. Lean: `congrArg f h`.
