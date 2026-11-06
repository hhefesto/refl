---
learning_goals:
  - "`dec_eq(1n+m, 1n+n)` reduces to `dec_eq(m, n)`, so a decision can recurse."
  - "`match` on two values at once."
  - "Reading a helper from the statement and using it."
hints:
  - text: "Write `match m n:` with four cases: `case 0n 0n:`, `case 0n 1n+q:`, `case 1n+p 0n:` and `case 1n+p 1n+q:`. Three of them you already know how to do."
  - text: "`0n 0n` is `Refl.Yes{{==}}`, and the two mixed cases use `Logic.zero_ne_succ`, one of them with the equation flipped. In the last, the recursive call `dec_eq(p, q)` decides the smaller question, and `map_succ` lifts its answer."
  - text: "`case 0n 1n+q:` is `Refl.No{Logic.zero_ne_succ(q)}`. `case 1n+p 0n:` is `Refl.No{e => Logic.zero_ne_succ(p, Equal.sym(Nat, 1n+p, 0n, e))}`. `case 1n+p 1n+q:` is `map_succ(p, q, dec_eq(p, q))`."
example_explanation: |-
  1. Split the number as far as the statement needs: `0n`, `1n` and `2n+p`.
  2. Only `1n` equals `1n`, with evidence `{==}`.
  3. Every other number differs by a constructor, so the refutation uses `Logic.zero_ne_succ`. The exercise compares two numbers, so it also needs a recursive decision.
---
Are two numbers equal? Here's a decision procedure for that, and it's the one you'll use for the rest of the game.

You need all four combinations of `0n` and `1n+`, so match on both at once, `match m n:`. Three of them are like the last level. The new one is when both numbers are successors, because then the answer depends on the smaller numbers: `1n+m` equals `1n+n` exactly when `m` equals `n`. So decide `dec_eq(p, q)` first, with a recursive call, and turn its answer into an answer to the bigger question.

Turning one into the other takes a little work, so the statement gives you a helper:

```
def map_succ(m, n, d):
  match d:
    case Refl.Yes{p}:
      Refl.Yes{Equal.cong(Nat, Nat, x => 1n+x, m, n, p)}
    case Refl.No{np}:
      Refl.No{e => np(Equal.cong(Nat, Nat, pred, 1n+m, 1n+n, e))}
```

Read it, because each line is a small proof. If `p` proves `m == n`, then `Equal.cong` lifts it. And if `np` refutes `m == n`, then to refute `1n+m == 1n+n` you take `e`, peel off the `1n+` with `pred`, as in `succ_inj`, and hand the result to `np`.

<!-- @conclusion -->
`Logic.dec_eq` is now in your inventory, and Equality World uses it a lot. Any function that compares numbers and then has to *prove* something about the result starts from a decision like this one.
