---
id: sym-trans
index: 7
title: "sym and trans"
learning_goals:
  - "`sym : x ≡ y → y ≡ x` flips an equation; `trans : x ≡ y → y ≡ z → x ≡ z` chains two."
  - "Read a lemma's type to know which argument goes where."
unlocks:
  lemmas:
    - name: "sym"
      agda: "sym"
      lean: "Eq.symm"
      doc: "sym.md"
    - name: "trans"
      agda: "trans"
      lean: "Eq.trans"
      doc: "trans.md"
hints:
  - text: "You have `p : y ≡ x` and `q : y ≡ z` and want `x ≡ z`. `trans` needs its first argument to start at `x`: flip `p` with `sym`."
  - text: "`trans (sym p) q`. Try **Refine** with `trans` first and watch it create two holes for the two equations; then Give each."
    hidden: true
---
Two more inventory lemmas, both proved by pattern matching on `refl`:

```agda
sym   : ∀ {A : Set} {x y : A}   → x ≡ y → y ≡ x
trans : ∀ {A : Set} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
```

This level is a small exercise in reading types: which equation goes where.
Use **Refine** with `trans` to let Agda open the argument holes for you.

<!-- @conclusion -->
Chains of `trans` get unreadable fast. World 1 unlocks `≡-Reasoning`, the
`begin … ≡⟨ … ⟩ … ∎` notation that is just `trans` with the intermediate
terms written out.
