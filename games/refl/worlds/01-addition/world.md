---
id: addition
title: "Addition World"
dependencies: [tutorial]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
The classic: commutativity, associativity and friends, proved by induction, plus a way of
writing proofs that keeps them readable: a **chain of equations**, naming every term it passes
through. In Agda it looks like this:

```agda
begin
  (x + y) + z ≡⟨ +-assoc x y z ⟩
  x + (y + z) ≡⟨ cong (x +_) (+-comm y z) ⟩
  x + (z + y) ∎
```

Lean writes the same chain with `calc`, and Bend with nested `Equal.trans`. It is nothing but
transitivity with the intermediate terms written down, and it is how long proofs are written in
practice. The lessons show each language's own spelling.
