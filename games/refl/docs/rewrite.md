```agda
name args rewrite eq = rhs
```

Rewrites the goal (and context) with `eq : lhs ≡ rhs`, left to right, before the right-hand side is checked. Several equations: `rewrite eq₁ | eq₂`. It is sugar for a `with` abstraction (World 4). Lean: `rw [eq]`.

**In Bend 2** the same move is `%h : P` on its own line, followed by the rest
of the proof. `P` is the goal with `_` marking the equation's *right-hand*
side: with `h : {x == 3n : Nat}` and the goal `{Refl.add(x, 2n) == 5n : Nat}`,
write `%h : {Refl.add(x, 2n) == 2n+_ : Nat}` (`5n` is `2n+3n`) and the goal
becomes `{Refl.add(x, 2n) == 2n+x : Nat}`, which is `{==}`.
