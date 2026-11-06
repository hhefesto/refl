---
title: "Hedberg: decidable equality gives UIP"
learning_goals:
  - "`p == q` for two proofs of the same equation isn't automatic."
  - "With decidable equality it's provable: canonicalise every proof through the decision."
  - "Filling in a chain whose intermediate terms are given."
hints:
  - text: "Press **Goal** on `?first`. It's `p` against `p` rebuilt from `canon`. That's `Equality.canon_inv(x, y, p)`, pointing the other way."
  - text: "`?third` is `Equality.canon_inv(x, y, q)`, as it stands. `?second` changes `canon(x, y, p)` to `canon(x, y, q)` under the `Equal.trans`: that's `Equality.canon_const` under an `Equal.cong`, and it takes the decision as an argument."
  - text: "`?first` is `Equal.sym({x == y : Nat}, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, p)), p, Equality.canon_inv(x, y, p))`. `?second` is `Equal.cong({x == y : Nat}, {x == y : Nat}, r => Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), r), Equality.canon(x, y, p), Equality.canon(x, y, q), Equality.canon_const(x, y, Logic.dec_eq(x, y), p, q))`. `?third` is `Equality.canon_inv(x, y, q)`."
example_explanation: |-
  1. Two composites differ only in their last argument.
  2. `Equal.cong` carries `h : {p == q : …}` under the function `r => Equal.trans(Nat, x, y, z, e, r)`.
  3. That is the whole proof. The middle step of the exercise is the same idea, with `canon` in the composite.
---
Here's the theorem: any two proofs of the same equation on `Nat` are equal.

```
law eq_irrelevant:
  for +x: Nat
  for +y: Nat
  for +p: {x == y : Nat}
  for +q: {x == y : Nat}
  {p == q : {x == y : Nat}}
```

This property is called **UIP**, for *uniqueness of identity proofs*. It's a real theorem here, and **Hedberg's theorem** says that any type with decidable equality has it.

You did the hard work in the last two levels. `canon_inv` says that any proof can be rebuilt from its canonical version, and `canon_const` says that every proof has the same canonical version. Put the two together:

1. Start from `p`, and rewrite it as `p` rebuilt from `canon`.
2. Change `canon(x, y, p)` to `canon(x, y, q)`. They're equal, whatever `p` and `q` are.
3. What you have now is `q` rebuilt from `canon`. So that's `q`.

The template has those three steps as a chain of equations *between proofs*, so its type argument is `{x == y : Nat}`, not `Nat`. Each hole is one lemma, though it takes some typing, since Bend wants the endpoints.

<!-- @conclusion -->
You've proved a real theorem about the structure of proofs. Bend's `{==}` doesn't make this automatic, and Lean's proof irrelevance does. That's a real difference between proof assistants, and now you've seen both sides.
