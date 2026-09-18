`{==}` proves equality when both endpoints compute to the same expression.

```bend
law numeric_example:
  {Refl.add(3n, 1n) == 4n : Nat}
def numeric_example():
  {==}
```