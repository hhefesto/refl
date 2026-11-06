---
id: inspect
index: 7
title: "The old inspect idiom"
learning_goals:
  - "Before `with … in`, the same effect was `with e | inspect f x` and a pattern `[ eq ]`."
  - "Recognising it in older code."
unlocks:
  syntax:
    - name: "inspect / [_]"
      bend2: "Saw{…}"
      lean: "generalize"
      doc: "inspect.md"
hints:
  - text: "It's the last level's proof in old clothes. Write `g-nonzero n h with n ≡ᵇ 0 | inspect (n ≡ᵇ_) 0`, then a clause for each result. `(n ≡ᵇ_)` is the function and `0` its argument."
  - text: "`... | true | [ eq ]` gives you `eq : (n ≡ᵇ 0) ≡ true`, which is what `≡ᵇ⇒≡` wants. In the `false` case you don't need the equation, so `_` will do."
  - text: "`... | true | [ eq ] = ⊥-elim (h (≡ᵇ⇒≡ n 0 eq))`, and `... | false | _ = refl`."
---
`with … in` is fairly recent. Before it existed, people remembered a test's result with a trick, and you'll
still run into it in older code. It's worth doing once so that you recognise it when you do.

The trick is a small record that holds one equation:

```agda
record Reveal_·_is_ {A B : Set} (f : A → B) (x : A) (y : B) : Set where
  constructor [_]
  field eq : f x ≡ y

inspect : ∀ {A B : Set} (f : A → B) (x : A) → Reveal f · x is f x
inspect f x = [ refl ]
```

`inspect f x` starts as a proof of `f x ≡ f x`. Now use it in a `with`: `with f x | inspect f x`. The `with`
replaces every `f x` by the value you match on, *including the right side of that equation*. So once you've
matched the first column against `true`, the second column says `f x ≡ true`. Pattern match on `[ eq ]` to get
the equation.

The statement here is the previous level again, for the same function called `g`. Reprove it this way. The one
fiddly part is writing the test `n ≡ᵇ 0` as a function applied to an argument: `(n ≡ᵇ_)` is a section, and `0` is
what it's applied to.

<!-- @conclusion -->
When you see `inspect` and `[_]` in a file, read it as `with … in eq`. They do the same job, and `with … in` is
the modern way to write it.
