---
id: addition
title: "Addition World"
dependencies: [tutorial]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
The classic: `+-comm`, `+-assoc` and friends, proved by induction, plus the
notation that keeps such proofs readable — **equational reasoning**:

```agda
begin
  (x + y) + z ≡⟨ +-assoc x y z ⟩
  x + (y + z) ≡⟨ cong (x +_) (+-comm y z) ⟩
  x + (z + y) ∎
```

You met this chain in the Tutorial, where every step was pure computation and the
brackets stayed empty. Here the brackets carry lemmas. It is nothing but `trans`
with the intermediate terms written down, and it is how long Agda proofs are
written in practice.
