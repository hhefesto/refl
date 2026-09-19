A typed local proof makes the proposition explicit:

```agda
let same : zero ≡ zero
    same = refl
in same
```

`let` introduces a local name. `same : …` declares its type, `same = …`
defines its value, and `in same` returns that value. Align both `same`
lines. The colon is a type declaration; `≡` is the equality being proved.
