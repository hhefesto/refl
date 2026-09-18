```agda
f args with e
... | pattern₁ = rhs₁
... | pattern₂ = rhs₂
```
Match on the value of an expression. The goal (and any hypothesis mentioning `e`) is abstracted over it. Several scrutinees: `with e₁ | e₂`.
