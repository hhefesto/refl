---
learning_goals:
  - "Pulling a constant out of a sum, in miniature."
  - "Induction on a list, with distributivity in the step."
hints:
  - text: "`match xs:`, with `case Nil{}:` and `case Con{h, t}:`. The second one's **Goal** is `{Refl.add(Addition.sum(scale(c, t)), Refl.mul(c, h)) == Refl.mul(c, Refl.add(Addition.sum(t), h)) : Nat}`."
  - text: "Use the recursive call on the left summand, under `n => Refl.add(n, Refl.mul(c, h))`. That reaches `Refl.add(Refl.mul(c, Addition.sum(t)), Refl.mul(c, h))`, and the right side is `mul_add` backwards."
  - text: "`Equal.trans(Nat, Refl.add(Addition.sum(scale(c, t)), Refl.mul(c, h)), Refl.add(Refl.mul(c, Addition.sum(t)), Refl.mul(c, h)), Refl.mul(c, Refl.add(Addition.sum(t), h)), Equal.cong(Nat, Nat, n => Refl.add(n, Refl.mul(c, h)), Addition.sum(scale(c, t)), Refl.mul(c, Addition.sum(t)), sum_factor(c, t)), Equal.sym(Nat, Refl.mul(c, Refl.add(Addition.sum(t), h)), Refl.add(Refl.mul(c, Addition.sum(t)), Refl.mul(c, h)), Multiplication.mul_add(c, Addition.sum(t), h)))`."
example_explanation: |-
  1. Match on the list: at `Nil{}`, both sides compute to `0n`, so `{==}`.
  2. At `Con{h, t}`, the first term is `0n`, and adding it computes away.
  3. So the recursive call is already the goal. The exercise follows the same plan with `mul_add`: unfold, use the recursive call under `Equal.cong`, distribute.
---
Pulling a constant out of a sum is a step you'll see in nearly every proof that does algebra with sums: `c·a₀ + c·a₁ + …` equals `c·(a₀ + a₁ + …)`. Here it is for the list `sum` from Addition World:

```
def scale(+c: Nat, xs: +List<Nat>) -> +List<Nat>:
  match xs:
    case Nil{}:
      []
    case Con{h, t}:
      Refl.mul(c, h) <> scale(c, t)
```

`scale(c, xs)` multiplies every element of `xs` by `c`, and the statement says that summing afterwards is the same as summing and then multiplying.

The proof is an induction on `xs`, because the recursion in `sum` looks at it. The step has the same shape as `mul_assoc`: use the recursive call on one summand, then use distributivity to line the two sides up. You've done every part of this before.

<!-- @conclusion -->
A lemma that looked forbidding in a textbook turned out to be an induction you could already do.

**Multiplication World complete.** If you haven't been to Logic World yet, it's next and changes the subject: types as propositions, pairs as *and*, functions as *implies*.
