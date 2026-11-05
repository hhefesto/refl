---
id: reading-languages
index: 12
title: "Reading: languages as predicates"
learning_goals:
  - "A language is a predicate; union is `⊎` pointwise, intersection is `×` pointwise."
  - "Proofs of membership are data, and lemmas about languages are functions on that data."
hints:
  - text: "Ask for the **Goal**. It has unfolded `∪` and `∩`: the goal is `P n ⊎ Q n`, and `pq : P n × Q n` is in the context."
  - text: "**Case split** on `pq`, giving `(proj₃ , proj₄)`. You now hold a proof for each of `P n` and `Q n`, and the goal only wants one side. Either choice works."
  - text: "`∩⊆∪ P Q n (p , _) = inj₁ p`, where `_` means you don't need that part. `inj₂` with the other component is just as good."
---
In *Symbolic and Automatic Differentiation of Languages* (ICFP 2021), Conal Elliott treats a
formal language as a predicate on strings: `P s` is the statement "`s` is in the language".
Here is that idea, with strings replaced by numbers to keep things simple:

```agda
Pred = ℕ → Set
(P ∪ Q) n = P n ⊎ Q n
(P ∩ Q) n = P n × Q n
```

Read the definitions the way a logician would. A number is in the union if it's in `P` or
in `Q`. It's in the intersection if it's in `P` and in `Q`. All the set theory you know turns
into the logic you've just learned.

Prove that intersection is contained in union: anything in both is in at least one. The
statement `∩⊆∪` gives you `P`, `Q`, `n` and a proof of membership in `P ∩ Q`, and asks for a
proof of membership in `P ∪ Q`. **Goal** will unfold both for you, and from there this is
two moves you already know.

<!-- @conclusion -->
This is the Curry–Howard view of formal languages. `P n` is the *type of parses* of `n`, and
`∩⊆∪` is a function that turns a parse for both into a parse for either. A proof about a
language is a program that manipulates parses.

**Logic World complete.** Equality World needs this world and Addition World.
