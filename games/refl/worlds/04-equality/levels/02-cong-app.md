---
id: cong-app
index: 2
title: "Function equality and ≗"
learning_goals:
  - "`cong-app : f ≡ g → ∀ x → f x ≡ g x` — equal functions agree everywhere."
  - "`f ≗ g` (pointwise equality) is the equality most developments use for functions."
unlocks:
  lemmas:
    - name: "cong-app"
      agda: "cong-app"
      lean: "congrFun"
    - name: "≗-trans"
      agda: "≗-trans"
hints:
  - text: "`cong-app`: **Case split** on `e`, as in the last level. `f` and `g` become the same function."
  - text: "`≗-trans`: the goal is `f x ≡ h x`, and in the context `p` and `q` are functions. `p x : f x ≡ g x` and `q x : g x ≡ h x`. Chain them."
  - text: "`cong-app refl x = refl`, and `≗-trans p q x = trans (p x) (q x)`."
---
What does it mean for two functions to be equal? There are two different answers, and this
level is about the gap between them.

The first answer is `f ≡ g`: they're the same function. The second is `f ≗ g`, which you'll
find defined in the statement:

```agda
f ≗ g = ∀ x → f x ≡ g x
```

They agree at every input. This is called **pointwise** equality.

Equal functions certainly agree everywhere, and that's `cong-app`, your first lemma here. It's
the mirror of `cong`: `cong` fixes the function and changes the argument, and `cong-app` fixes
the argument and changes the function.

The other direction, from `f ≗ g` to `f ≡ g`, is **function extensionality**, and Agda can't
prove it. Two functions may agree everywhere and yet be defined differently. So real
developments state equalities of functions with `≗`, and need its laws. Your second lemma is
one of them: `≗-trans`.

Since `f ≗ g` is a function type, the proof of `≗-trans` takes `x` on the left of `=`, and `p`
and `q` are functions you can apply.

<!-- @conclusion -->
Most Agda libraries compare functions with `_≗_`, and the standard library has it under that
name. When you see it, read it as "equal at every input".
