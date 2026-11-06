---
id: implication
index: 1
title: "Implication is a function"
learning_goals:
  - "A proof of `A → B` is a function."
  - "Introduce hypotheses as arguments, or with `λ`."
unlocks:
  syntax:
    - name: "λ"
      bend2: "x => e"
      lean: "fun"
      doc: "lambda.md"
hints:
  - text: "Select the hole and press **Refine** with the box empty. Agda writes `λ x x₁ → ?`. Then press **Check** and ask for the new hole's **Goal**: it wants a `B`, with `x : A` and `x₁ : A → B` in the context."
  - text: "Nothing is known about `B`, so there is only one way to get one: apply the function you have to the value you have. `x₁ x`. If you named the arguments yourself, that's `modus-ponens a f = f a`."
---
Logic World starts from a change of viewpoint. A proposition is a type, and a proof of
it is a value of that type. You've used this since the Tutorial without saying so: a
proof of `x ≡ y → suc x ≡ suc y` was a function.

Here is the oldest rule in logic, **modus ponens**: from `A`, and `A` implies `B`,
conclude `B`. In Agda it's the type `A → (A → B) → B`, for any types `A` and `B`. `Set`
is the type of types, so `∀ {A B : Set}` means "for any two types".

To prove it you have to take the two hypotheses as arguments, and there are two ways
of doing that. You can name them on the left of `=`, by editing the line to
`modus-ponens a f = ?`. Or you can write a `λ` on the right.

**Refine** with an *empty* box writes the `λ` for you: Agda looks at the function type
and introduces its arguments, making up names as it goes. They're only names, and you
can change them to something clearer.

<!-- @conclusion -->
`A` and `B` are arbitrary types. Nothing about them is known, so the only possible
proof is the one that uses the hypotheses. That is the sense in which this is *logic*:
the proof goes through because of the shape of the statement, whatever `A` and `B` are.
