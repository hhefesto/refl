---
learning_goals:
  - "`dec_eq (succ m) (succ n)` reduces to `dec_eq m n`, so a decision can recurse."
  - "`fun | rfl => …` takes apart an equation."
  - "`match` on two values at once."
hints:
  - text: "Write `match m, n with` and four lines: `| zero, zero => sorry`, `| zero, succ _ => sorry`, `| succ _, zero => sorry` and `| succ m, succ n => sorry`. Three of them you already know how to do."
  - text: "`zero, zero` is `isTrue rfl`, and the two mixed cases are `isFalse (fun h => by cases h)`. In the last, the recursive call `dec_eq m n` decides the smaller question, and `map_succ` lifts its answer."
  - text: "`| succ m, succ n => map_succ (dec_eq m n)`."
example_explanation: |-
  1. Split the number as far as the statement needs: `zero`, `succ zero` and `succ (succ _)`.
  2. Only `succ zero` equals `succ zero`, with evidence `rfl`.
  3. Every other number differs by a constructor, so the refutation is `fun h => by cases h`. The exercise compares two numbers, so it also needs a recursive decision.
---
Are two numbers equal? Here's a decision procedure for that, and it's the one you'll use for the rest of the game.

The statement ends in `:=`, not `:= by`, because this one is easiest to write as a term, using `match`:

```lean
  match m, n with
  | zero, zero => sorry
  -- and so on
```

You need all four combinations of `zero` and `succ`. Three of them are like the last level. The new one is when both numbers are successors,
because then the answer depends on the smaller numbers: `succ m` equals `succ n` exactly when `m` equals `n`. So decide `dec_eq m n` first, with a
recursive call, and turn its answer into an answer to the bigger question.

Turning one into the other takes a little work, so the statement gives you a helper:

```lean
def map_succ {m n : MyNat} : Decidable (m = n) → Decidable (succ m = succ n)
  | isTrue p => isTrue (congrArg succ p)
  | isFalse np => isFalse (fun | rfl => np rfl)
```

Read it, because each line is a small proof. If `p` proves `m = n`, then `congrArg succ p` proves `succ m = succ n`. And if `np` refutes `m = n`,
you must refute `succ m = succ n`. `fun | rfl => …` matches the proof against `rfl`, which forces `m` and `n` to be the same, so `np rfl` is `False`.

<!-- @conclusion -->
`dec_eq` is now in your world's library, and Equality World uses it a lot. Any function that compares numbers and then has to *prove* something about
the result starts from a decision like this one.
