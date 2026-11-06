---
id: pattern-lambda
index: 4
title: "Pattern-matching lambdas"
learning_goals:
  - "`λ { pat → e; … }` is an anonymous function defined by cases."
  - "`λ ()` is the anonymous absurd function."
unlocks:
  syntax:
    - name: "λ { … }"
      bend2: "e =>"
      lean: "fun | rfl"
      doc: "pattern-lambda.md"
forbids: ["sym", "Eq.symm", "Equal.sym"]
hints:
  - text: "Replace the hole with `λ { refl → ? }` and press **Check**. The new hole's **Goal** is `x ≡ x`."
  - text: "Matching against `refl` has made `y` into `x`, so the goal is a thing equal to itself. `sym′ = λ { refl → refl }`."
---
Up to now, pattern matching has needed a named function with clauses. Sometimes you just want
a small function in the middle of an expression. You saw one in `map-suc`, in Logic World:

```agda
no (λ { refl → ¬p refl })
```

`λ { pattern → body }` is an anonymous function defined by cases, with `;` between them if
there are several. It can do what any clause can do, including matching an equation against
`refl`.

In this level the template has no arguments on the left of `=`, so the whole proof has to be an
expression on the right. Prove `sym`, which is forbidden here, by writing a lambda that matches
its argument.

This is the same move as this world's first level, in a different spelling. A plain **Give** of a
`λ` with a hole inside it is fine: you can type a `?` in the body, and **Check** will give you its
goal.

<!-- @conclusion -->
You'll see these all over real code. They're the usual way to pass a small proof by cases to
something like `mk⇔`, without naming it. And `λ ()` from Logic World is the same idea with no
cases at all.
