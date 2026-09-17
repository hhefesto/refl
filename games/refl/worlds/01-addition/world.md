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

It is nothing but `trans` with the intermediate terms written down, and it is
how every serious Agda development (Spectra2, formalTransformer, felix) writes
its proofs.
