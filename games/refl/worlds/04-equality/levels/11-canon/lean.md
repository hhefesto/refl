---
learning_goals:
  - "Decidable equality gives a way to turn any proof into a canonical one."
  - "Definitions can be built on `Prop`, and proof irrelevance still applies."
hints:
  - text: "**Goal** shows `⋯ = p`, with the left side elided, because it's a proof."
  - text: "Both sides are proofs of `x = y`, so `rfl` closes it."
example_explanation: |-
  1. `p` and `q` are two proofs of `x = x`.
  2. Lean doesn't distinguish proofs of the same proposition.
  3. So `rfl` is the whole proof. The exercise is the same, with a more complicated left side.
---
Here's the idea behind the theorem, as it plays out in a system without proof irrelevance. We have `dec_eq`, which decides whether two numbers are equal and returns a proof if they are. So take *any* proof `p : x = y`, ignore it, ask `dec_eq x y` instead, and return the proof that comes back.

```lean
def canon {x y : MyNat} (p : x = y) : x = y :=
  match dec_eq x y with
  | isTrue q => q
  | isFalse nq => absurd p nq
```

(The `isFalse` case is impossible, since `p` refutes it. That's the only thing `p` is used for.)

Since `canon` never looks at `p`, every proof goes to the same canonical one. And you can get back from the canonical proof to the one you started with, by composing it with the inverse of `canon rfl`:

```lean
theorem canon_inv {x y : MyNat} (p : x = y) : Eq.trans (Eq.symm (canon rfl)) (canon p) = p
```

That's a mouthful, and the proof of it is the mouthful's opposite. Press **Goal** first, and see what Lean thinks of the left side.

<!-- @conclusion -->
So every proof can be rebuilt from `canon p`, and `canon p` doesn't depend on `p`. That's what the next level needs, in a system where it takes work.
