---
id: reading-languages
index: 10
title: "Reading: languages as predicates"
learning_goals:
  - "A language is a predicate; union is `⊎` pointwise, intersection is `×` pointwise."
  - "Proofs of membership are data, and lemmas about languages are functions on that data."
hints:
  - text: "Unfold: `(P ∩ Q) n` is `P n × Q n`, `(P ∪ Q) n` is `P n ⊎ Q n`. Take the pair apart and pick a side."
  - text: "`∩⊆∪ P Q n (p , _) = inj₁ p`."
    hidden: true
---
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
