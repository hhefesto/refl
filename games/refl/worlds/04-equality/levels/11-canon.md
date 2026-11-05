---
id: canon
index: 11
title: "A canonical proof"
learning_goals:
  - "Decidable equality gives a way to turn any proof into a canonical one."
  - "The canonical proof doesn't depend on the proof you started with."
hints:
  - text: "**Case split** on `p`. The two ends of `p` are separate variables, so this is allowed, and `canon p` becomes `canon refl`."
  - text: "The hole list now says `trans (sym (canon refl)) (canon refl) ≡ refl`. **Goal** prints `canon refl | x ≟ x` for `canon refl`, because it is stuck on the decision, but it is the same term. That is last level's lemma, with `e` being `canon refl`."
  - text: "`canon-inv refl = trans-symˡ (canon refl)`."
---
Here's the idea behind the theorem. On `ℕ` we have `_≟_`, which decides whether two numbers are equal and returns a proof
if they are. So take *any* proof `p : x ≡ y`, ignore it, ask `x ≟ y` instead, and return the proof that comes back.

```agda
canon : ∀ {x y : ℕ} → x ≡ y → x ≡ y
canon {x} {y} p with x ≟ y
... | yes q = q
... | no ¬q = ⊥-elim (¬q p)
```

(The `no` case is impossible, since `p` refutes it. That's the only thing `p` is used for.)

This gives two facts. The first is `canon-const`, which is in the statement: since `canon` never looks at `p`, `canon p`
and `canon q` are the same for any two proofs. Every proof goes to the same canonical one.

The second is yours to prove. Can you get back from the canonical proof to the one you started with? Yes: compose it with
the inverse of `canon refl`, and you've got `p` again.

```agda
canon-inv : ∀ {x y : ℕ} (p : x ≡ y) → trans (sym (canon refl)) (canon p) ≡ p
```

That's a mouthful, but you only have to do what you've done since the start of this world. Then look carefully at what the
goal has turned into. **Goal** will print `canon refl` as `canon refl | x ≟ x`, since it can't compute until the decision is known,
but the hole list shows it plainly. You proved this last level.

<!-- @conclusion -->
So every proof `p` can be rebuilt from `canon p`, and `canon p` doesn't depend on `p`. You can probably see where this is
going.
