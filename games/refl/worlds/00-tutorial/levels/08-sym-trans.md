---
id: sym-trans
index: 8
title: "sym and trans"
learning_goals:
  - "`sym : x ≡ y → y ≡ x` flips an equation; `trans : x ≡ y → y ≡ z → x ≡ z` chains two."
  - "Read a lemma's type to know which argument goes where."
unlocks:
  lemmas:
    - name: "sym"
      agda: "sym"
      lean: "Eq.symm"
      bend2: "Equal.sym"
      doc: "sym.md"
    - name: "trans"
      agda: "trans"
      lean: "Eq.trans"
      bend2: "Equal.trans"
      doc: "trans.md"
hints:
  - text: "Select the hole, put `trans` in the box and press **Refine**. Agda opens two holes, and **Goal** tells you what each one needs."
  - text: "The first hole must get from `x` to the middle, and you have `p : y ≡ x`, which points the wrong way. Flip it with `sym`. The second hole is then `q`."
  - text: "`flip-chain p q = trans (sym p) q`."
---
Two more inventory lemmas:

```agda
sym   : ∀ {A : Set} {x y : A}   → x ≡ y → y ≡ x
trans : ∀ {A : Set} {x y z : A} → x ≡ y → y ≡ z → x ≡ z
```

`sym` flips an equation around. `trans` chains two equations that meet in the
middle: if you can get from `x` to `y` and from `y` to `z`, you can get from `x`
to `z`. Between them they are most of what you will ever do with equations.

This level is a small exercise in reading types, because a lemma only fits when
its arguments point the right way. Look at the context: you have `p : y ≡ x` and
`q : y ≡ z`, and you owe `x ≡ z`. Draw it on paper if that helps, with `y` in the
middle and an arrow for each equation.

Use **Refine** with `trans` to let Agda open the argument holes for you, then ask
for each hole's **Goal**. Refining before you know the whole proof is normal: the
new goals tell you what is left.

<!-- @conclusion -->
Chains of `trans` get unreadable fast, and you have already met the way out. The
`begin … ≡⟨⟩ … ∎` chain from the very first level is `trans` with the intermediate
terms written down. Every step there was computation, so its brackets stayed
empty. In Addition World the brackets start carrying lemmas.
