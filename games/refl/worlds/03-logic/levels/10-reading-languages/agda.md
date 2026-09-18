---
example_explanation: |-
  1. Evaluate the membership function at `n`.
  2. Extract its second component.
  3. Inject it into the left side of the target union. Unfold the exercise's predicate operations before making its choice.
hints:
- hidden: false
  text: Membership in a predicate is evidence; inclusion transforms that evidence.
- hidden: true
  text: Unfold intersection to a pair and union to a tagged choice. Only one component
    is needed by the result.
- hidden: true
  text: Decompose `pq` into a pair, then inject one of its components.
learning_goals:
- A language is a predicate; union is `⊎` pointwise, intersection is `×` pointwise.
- Proofs of membership are data, and lemmas about languages are functions on that
  data.
title: 'Reading: languages as predicates'
---
Membership in a predicate is evidence; inclusion transforms that evidence.

From `Language.lagda` (ICFP 2021), with strings replaced by numbers:

```agda
Pred = ℕ → Set
(P ∪ Q) n = P n ⊎ Q n
(P ∩ Q) n = P n × Q n
```

Prove that intersection is contained in union. The statement has the
definitions; you prove the inclusion.


<!-- @conclusion -->

This is the Curry–Howard view of formal languages: `P n` is the *type of
parses* of `n`, and `∩⊆∪` is a function turning a parse for both into a
parse for either. Worlds 12 and 13 build the whole ν/δ calculus on it.

**Logic World complete.**
