---
title: "A canonical proof"
learning_goals:
  - "Decidable equality gives a way to turn any proof into a canonical one."
  - "The canonical proof doesn't depend on the proof you started with."
hints:
  - text: "Use `%E@p : …` again, with `_` for `y` and `E` for `p`. The motive is `{Equal.trans(Nat, x, x, _, Equal.sym(Nat, x, x, canon(x, x, {==})), canon(x, _, E)) == E : {x == _ : Nat}}`."
  - text: "The goal then has `canon(x, x, {==})` in both places, and it's last level's lemma."
  - text: "That line, then `Equality.trans_sym(Nat, x, x, canon(x, x, {==}))`."
example_explanation: |-
  1. `pick_proof` is a stand-in for `canon` that returns its argument unchanged.
  2. J reduces the goal to the case `p` is `{==}`.
  3. That's exactly `trans_sym` at `pick_proof(x, x, {==})`. The exercise has `canon` in the same places, and its proof has the same shape.
---
Here's the idea behind the theorem. On `Nat` we have `Logic.dec_eq`, which decides whether two numbers are equal and returns a proof if they are. So take *any* proof `p`, ignore it, ask `dec_eq` instead, and return the proof that comes back.

```
def canon_of(x, y, d, p):
  match d:
    case Refl.Yes{q}:
      q
    case Refl.No{n}:
      Empty.absurd({x == y : Nat}, n(p))

def canon(+x: Nat, +y: Nat, p: {x == y : Nat}) -> {x == y : Nat}:
  canon_of(x, y, Logic.dec_eq(x, y), p)
```

(The `No` case is impossible, since `p` refutes it. That's the only thing `p` is used for.)

This gives two facts. The first is `canon_const`, which is in the statement: since `canon_of` never looks at `p`, it gives the same result for any two proofs. Every proof goes to the same canonical one.

The second is yours to prove. Can you get back from the canonical proof to the one you started with? Yes: compose it with the inverse of `canon(x, x, {==})`, and you've got `p` again.

The statement is a mouthful, but you only have to do what you did last level. Then look carefully at what the goal has turned into. You proved it last level.

<!-- @conclusion -->
So every proof `p` can be rebuilt from `canon(x, y, p)`, and that doesn't depend on `p`. You can probably see where this is going.
