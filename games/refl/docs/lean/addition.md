`+` uses the game's `MyNat.add`, which computes on its **second argument**:

```lean
def add : MyNat → MyNat → MyNat
  | m, zero => m
  | m, succ n => succ (add m n)
```

The arrows describe two inputs and one output. Each `|` introduces a case;
`=>` separates the inputs from the result. Zero returns `m`; a successor
wraps `succ` around the smaller addition.
