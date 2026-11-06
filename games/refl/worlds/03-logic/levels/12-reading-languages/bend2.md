---
learning_goals:
  - "A language is a predicate; union is `|` pointwise, intersection is `&` pointwise."
  - "Proofs of membership are data, and lemmas about languages are functions on that data."
hints:
  - text: "Press **Goal**. It has unfolded `union`: `Either<&1, &1, P(n), Q(n)>`, which is `P(n) | Q(n)`. And `pq` is a pair."
  - text: "Take the pair apart with `(p, q) = pq`. You now hold a proof for each of `P(n)` and `Q(n)`, and the goal only wants one side. Either choice works."
  - text: "`(p, q) = pq`, then `Inl{p}`. `Inr{q}` is just as good."
example_explanation: |-
  1. Unfold the membership at `n`, which is a pair.
  2. Extract its second part.
  3. Inject it into the left side of the target. Unfold the exercise's predicate operations before making its choice.
---
In *Symbolic and Automatic Differentiation of Languages* (ICFP 2021), Conal Elliott treats a formal language as a predicate on strings: `P(s)` is the statement "`s` is in the language". Here's that idea, with strings replaced by numbers to keep things simple:

```
def union(-P: Nat -> Type, -Q: Nat -> Type, n: Nat) -> Type:
  P(n) | Q(n)

def inter(-P: Nat -> Type, -Q: Nat -> Type, n: Nat) -> Type:
  P(n) & Q(n)
```

Read the definitions the way a logician would. A number is in the union if it's in `P` or in `Q`. It's in the intersection if it's in `P` and in `Q`. All the set theory you know turns into the logic you've just learned.

Prove that intersection is contained in union: anything in both is in at least one. The statement gives you a proof of membership in `inter(P, Q, n)` and asks for a proof of membership in `union(P, Q, n)`. **Goal** will unfold both, and from there this is two moves you already know.

<!-- @conclusion -->
This is the Curry–Howard view of formal languages. `P(n)` is the *type of parses* of `n`, and this lemma is a function that turns a parse for both into a parse for either. A proof about a language is a program that manipulates parses.

**Logic World complete.** Equality World needs this world and Addition World.
