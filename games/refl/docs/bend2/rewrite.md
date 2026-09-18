`%h : P` rewrites the goal with the equation `h : {a == b : T}`. `P` is the
goal with `_` marking the **right-hand** side `b`; after the line, the goal is
`P` with `a` in that place, and you go on proving that.

With `h : {x == 3n : Nat}` and the goal `{Refl.add(x, 2n) == 5n : Nat}`: `5n`
is `2n+3n`, so mark the `3n` inside it,

```
%h : {Refl.add(x, 2n) == 2n+_ : Nat}
{==}
```

and the goal becomes `{Refl.add(x, 2n) == 2n+x : Nat}`, which computes to
`{2n+x == 2n+x : Nat}` and is `{==}`. Note the direction: the marked side is
replaced by the *other* side of `h`. To rewrite the other way, use
`Equal.sym(T, a, b, h)`.
