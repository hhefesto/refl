---
learning_goals:
  - "`Equal.sym(T, a, b, e)` flips `e : {a == b : T}`; `Equal.trans(T, a, b, c, ab, bc)` chains."
  - "The type arguments (`T`, the endpoints) are explicit: read the goal to fill them in."
hints:
  - text: "From `p : {y == x : Nat}` and `q : {y == z : Nat}` you need `{x == z : Nat}`: flip `p`, then chain with `q`."
  - text: "`Equal.sym(Nat, y, x, p)` has type `{x == y : Nat}`; the endpoints are the sides of `p` in order."
    hidden: true
  - text: "`Equal.trans(Nat, x, y, z, Equal.sym(Nat, y, x, p), q)` is the whole proof; **Give** it."
    hidden: true
example_explanation: |-
  1. The first proof already runs from `a` to `b`.
  2. Reverse `q` to go from `b` to `c`.
  3. Compose with `Equal.trans`. The exercise reverses the first edge instead.
---
Base proves that equality is symmetric and transitive, as `Equal.sym` and
`Equal.trans`. Unlike Agda, the type and endpoint arguments are explicit, so
`Equal.sym(Nat, y, x, p)` says: in `Nat`, from `y == x` to `x == y`. Chaining
is `Equal.trans(Nat, x, y, z, …, …)` with the two proofs last.

<!-- @conclusion -->
Explicit endpoints are more typing but no guessing: every argument is
something you can read off the goal. `Equal.sym` and `Equal.trans` are in your
inventory.
