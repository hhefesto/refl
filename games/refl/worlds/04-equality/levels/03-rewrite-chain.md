---
id: rewrite-chain
index: 3
title: "Rewrite chains"
learning_goals:
  - "`rewrite p | q` applies several equations in order."
  - "Direction matters: `rewrite` uses the equation left to right; use `sym` to flip."
hints:
  - text: "The goal mentions `x` and `y`, and you have an equation for each. Edit the line to `two-three x y p q rewrite p | q = ?` and press **Check**."
  - text: "The hole list says `2 + 3 ≡ 5`, and **Goal** computes that to `5 ≡ 5`. You know what proves that."
  - text: "`two-three x y p q rewrite p | q = refl`."
---
In the Tutorial, `rewrite` took one equation. It can take several, separated by `|`:

```agda
name args rewrite eq₁ | eq₂ = rhs
```

They run in order, each one working on the goal the last one left. Here `p : x ≡ 2` and
`q : y ≡ 3`, and the goal is `x + y ≡ 5`.

`rewrite` is an edit you make to the left side of the clause, so you can't **Give** it. Edit the
line, leave a `?` on the right, press **Check** and read the goal it leaves behind.

Two details are worth knowing, for the day a `rewrite` doesn't do what you want. An equation
rewrites from left to right: every occurrence of its left side becomes its right side. If you
need the other direction, write `rewrite sym p`. And each equation only sees the goal *as the
previous one left it*, so the order can matter.

<!-- @conclusion -->
Real proofs are full of these chains, sometimes several lemmas long. Read one the way the checker
does, one equation at a time.
