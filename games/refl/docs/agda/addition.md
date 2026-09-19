The name `_+_` has two argument positions, so we write `m + n`.
Addition computes on its **second argument**:

```agda
m + zero  = m
m + suc n = suc (m + n)
```

The zero case returns `m`; the successor case wraps `suc` around a smaller
addition. These defining equations describe computation, not new proof goals.
