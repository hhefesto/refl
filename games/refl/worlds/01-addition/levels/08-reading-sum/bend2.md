---
learning_goals:
  - "A recursive function on a list."
  - "Lemmas about sums are proved by the same induction as lemmas about `add`."
hints:
  - text: "`match n:`, on the number of zeros. What is `sum(zeros(0n))`?"
  - text: "In the `1n+p` case the goal is `{sum(zeros(p)) == 0n : Nat}`: the last term is `0n`, and `Refl.add(_, 0n)` computes away. That leaves exactly the statement for the smaller `p`."
  - text: "`case 0n:` is `{==}`, and `case 1n+p:` is `sum_zeros(p)`."
example_explanation: |-
  1. Read the definition: `count(1n+p)` unfolds to `Refl.add(count(p), 1n)`, and that computes to `1n+count(p)`.
  2. So the goal at `1n+p` is `{1n+count(p) == 1n+p : Nat}`, which is `Equal.cong` of the recursive call.
  The exercise's `sum(zeros(n))` unfolds the same way, with `Refl.add(_, 0n)` computing away instead of `Refl.add(_, 1n)`.
---
Finite sums turn up everywhere in real mathematics, and proof libraries spend a lot of effort on lemmas about them: splitting a sum, reindexing it, pulling a term out. Those lemmas all look like this level.

In Bend the natural way to say a finite sum is over a list:

```
def sum(xs: +List<Nat>) -> Nat:
  match xs:
    case Nil{}:
      0n
    case Con{h, t}:
      Refl.add(sum(t), h)
```

(In other provers the terms would come from a function. In Bend a function can't be used twice, as functions aren't data, but a list of numbers can. `+List<Nat>` says this one may be copied.)

`zeros(n)` is a list of `n` zeros. Prove that their sum is zero.

Even with a list in the statement, nothing about the proof has changed: induct on the number the recursion looks at, then read each **Goal**.

<!-- @conclusion -->
A sum is a fold, and a lemma about a sum is an induction on its length. When you read lemmas about sums in real code, look for this shape.

**Addition World complete.**
