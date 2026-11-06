---
learning_goals:
  - "`exs n: Nat` in a law asks for a witness along with the proof."
  - "The witness is data: you choose it."
hints:
  - text: "The proof is a pair: a number, and a proof about it. Which `n` makes `Refl.add(n, 1n)` equal to `3n`?"
  - text: "With `2n` as the witness, the second part must prove `{3n == 3n : Nat}`."
  - text: "`(2n, {==})`."
example_explanation: |-
  1. Choose a witness, here `4n`.
  2. Substitute it into the claim, obtaining `{6n == 6n : Nat}`.
  3. `{==}` proves it. Choose a different witness for the exercise's equation.
---
How do you prove that something exists? In ordinary maths you might argue that it can't fail to. Here, you show it. A proof of "there is an `n` such that `P(n)`" is a **pair**: a particular number, called the **witness**, and a proof that it works.

In a law, that's what `exs` says:

```
law witness:
  exs n: Nat
  {Refl.add(n, 1n) == 3n : Nat}
```

You return `(n, proof)`. **Goal** prints the type as `Sigma<&1, &1, Nat, n => {1n+n == 3n : Nat}>`. That's the same `Sigma` that `&` is made of, and now you can see what it's for: the second part's type can mention the first part's *value*. That's why `Refl.add(n, 1n)` computed to `1n+n`, with `n` still unknown.

You pick the witness first, since it's data and the choice is yours. Then what the second part has to prove depends on what you picked.

<!-- @conclusion -->
Unlike classical existence, the pair *contains* the number. You can take a proof of existence and compute with what's inside it.

A pair `A & B` is the case where the second part's type doesn't mention the first.
