```agda
name args rewrite eq = rhs
```

Rewrites the goal (and context) with `eq : lhs ≡ rhs`, left to right, before the right-hand side is checked. Several equations: `rewrite eq₁ | eq₂`. It is sugar for a `with` abstraction (World 4). Lean: `rw [eq]`.
