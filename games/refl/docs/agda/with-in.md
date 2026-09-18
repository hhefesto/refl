```agda
f args with e in eq
... | true  = …   -- eq : e ≡ true
```
Like `with`, and remembers the equation in each branch. Replaces the older `inspect`/`[_]` idiom.
