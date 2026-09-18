`rfl` proves equality when both endpoints reduce to the same expression.

```lean
theorem numeric_example : (3 : MyNat) + 1 = 4 := by
  rfl
```