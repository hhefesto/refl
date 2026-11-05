---
id: with
index: 5
title: "with abstraction"
learning_goals:
  - "`with e` adds the value of `e` as a new column to match on."
  - "A function defined by `with` computes only once the scrutinee is known; lemmas about it repeat the same `with`."
unlocks:
  syntax:
    - name: "with"
      doc: "with.md"
  lemmas:
    - name: "δ-diag"
      agda: "δ-diag"
      lean: ""
hints:
  - text: "Press **Goal**: `(δ i i | i ≟ i) ≡ 1`. `δ` is stuck until `i ≟ i` is known. Edit the template to two lines: `δ-diag i with i ≟ i` and `... | d = ?`. Then **Check**, and **Case split** on `d`."
  - text: "You get `... | yes x = ?` and `... | no x = ?`. In the `yes` clause the goal is `1 ≡ 1`. In the `no` clause it's `0 ≡ 1`, which is false, so the case must be impossible. Read `x`'s type: `i ≡ i → ⊥`. Can you get a contradiction out of that?"
  - text: "`... | yes x = refl`, and `... | no x = ⊥-elim (x refl)`."
---
Here is the Kronecker delta, a function that's `1` when its two indices are equal and `0` when
they aren't. It's the identity matrix, written as a formula:

```agda
δ i j with i ≟ j
... | yes _ = 1
... | no  _ = 0
```

`with` is new. It matches on an *expression*, not on a variable: it computes `i ≟ j`, then treats
the result as an extra argument you can pattern match on. The dots `...` mean "the same left-hand
side as above". The result of `i ≟ j` is a `Dec`, so there are two cases.

Prove that the delta of an index with itself is `1`. Ask for the **Goal**, and it will look
strange: `(δ i i | i ≟ i) ≡ 1`. That's Agda telling you that `δ i i` is stuck, waiting for the value
of `i ≟ i`. You know it'll be `yes`, but Agda doesn't, because `i` is a variable.

So write the same `with` in your proof. It makes the two `i ≟ i` line up, and once you match on the
result, `δ` computes. Edit the clause by hand:

```agda
δ-diag i with i ≟ i
... | d = ?
```

**Check**, then **Case split** on `d`. One case is easy. The other case can't happen, but Agda needs
you to prove that.

<!-- @conclusion -->
This is one of the most common idioms in dependently typed code: a function defined by `with`, and
lemmas about it that repeat the same `with`. And `rewrite` is a `with` on an equation, which is the
box the Tutorial promised to open.
