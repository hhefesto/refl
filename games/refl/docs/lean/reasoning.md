A `conv` block focuses the goal on one part of it, so you can rewrite a single
side of an equation:

```lean
  conv =>
    lhs              -- now working on the left-hand side only
    change succ 3    -- replace it with a term that computes to the same thing
  conv =>
    rhs              -- and now the right
    change succ 3
```

`lhs` and `rhs` select a side; `change e` replaces whatever is in focus with
`e`, and is accepted only when `e` is **definitionally equal** to what it
replaces — so it restates, it never assumes. A wrong term is reported:
`'change' tactic failed, pattern … is not definitionally equal to target …`.

When both sides end up as the same term, `conv` closes the goal by itself:
there is nothing left to prove. Outside a `conv` block, `change` rewrites the
whole goal instead of one side.

(`conv_lhs` and `conv_rhs`, the one-line forms, come from Mathlib and are not
available here.)
