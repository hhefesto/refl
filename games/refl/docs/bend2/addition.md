Use `Refl.add(a, b)` for the game's addition. It computes on the **second
argument**, with these constructor rules:

```text
Refl.add(a, Zero{})  → a
Refl.add(a, Succ{p}) → Succ{Refl.add(a, p)}
```

In its definition, `match b` selects the case; `0n` means `Zero{}` and
`1n+p` matches a successor whose predecessor is named `p`.
