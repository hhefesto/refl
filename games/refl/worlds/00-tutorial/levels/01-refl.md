---
id: refl
index: 1
title: "refl"
learning_goals:
  - "Read natural numbers as zero and successors."
  - "Compute addition using its second argument."
  - "Distinguish an equality type from a proof of that type."
unlocks:
  commands: [load, goal, give]
  lemmas:
    - name: "refl"
      agda: "refl"
      lean: "rfl"
      bend2: "{==}"
      doc: "refl.md"
  syntax:
    - name: "natural numbers"
      agda: "ℕ, zero, suc"
      lean: "MyNat, zero, succ"
      bend2: "Nat, Zero{}, Succ{…}"
      doc: "numbers.md"
    - name: "equality"
      agda: "_≡_"
      lean: "="
      bend2: "{a == b : Nat}"
      doc: "equality.md"
    - name: "addition"
      agda: "_+_"
      lean: "+"
      bend2: "Refl.add"
      doc: "addition.md"
    - name: "explicit proof type"
      agda: "let, :, in"
      lean: "by, change"
      bend2: "(proof : Type)"
      doc: "explicit-proof.md"
hints:
  - text: "Start by unfolding addition and expanding both endpoints. Write `2` as `suc (suc zero)` and the right-hand `4` as `suc (suc (suc (suc zero)))`. Apply the rule for the second argument of `+`."
    hidden: true
  - text: "The left endpoint reduces as `2 + suc (suc zero)` → `suc (2 + suc zero)` → `suc (suc (2 + zero))` → `suc (suc 2)`. The first two steps use the successor rule; the last uses the zero rule."
    hidden: true
  - text: "Expand the remaining `2`: the left endpoint is `suc (suc (suc (suc zero)))`. The right endpoint has exactly that form too. The equality is a type asking for a proof; the computation has made its two endpoints identical."
    hidden: true
  - text: |-
      Make this normalized equality explicit with a typed local proof:

      ```agda
      two-plus-two =
        let same : suc (suc (suc (suc zero))) ≡ suc (suc (suc (suc zero)))
            same = refl
        in same
      ```

      `let` introduces a local name; `same : …` gives its type; `same = refl` supplies its value; `in same` returns that proof. Keep the two `same` lines aligned. `refl` proves equality of identical terms. Agda accepts this proof for the original statement because its endpoints compute to these terms.
    hidden: true
  - text: |-
      Now try the short proof:

      ```agda
      two-plus-two = refl
      ```

      The checker performs the very same reductions automatically. You can edit the whole definition and **Check**, or after checking the hole, select it and **Give** `refl` in the expression box.
    hidden: true
---
A natural number counts how many times we take a **successor**, starting at
zero. In Agda the type of natural numbers is `ℕ`, its first constructor is
`zero`, and `suc n` means the successor of `n` (one more).
Numerals are convenient notation for these constructor terms:

```agda
0  =  zero
1  =  suc zero
2  =  suc (suc zero)
4  =  suc (suc (suc (suc zero)))
```

These lines explain notation; they are not code to paste into the editor.
Parentheses group the argument of a function such as `suc`.

The fixed statement `two-plus-two : 2 + 2 ≡ 4` names a proposition:
`2 + 2 ≡ 4` is an **equality type**, saying the two numbers are equal.
The colon reads “has type”. A proof is a value of that type; the statement
itself is not the proof. Your definition below it currently contains `?`,
a hole where that proof belongs.

Before proving anything, compute. The game's addition has these two rules:

```agda
m + zero  = m
m + suc n = suc (m + n)
```

Here `m` and `n` stand for any natural numbers. Addition inspects its
**second argument**: zero returns `m`; a successor puts `suc` outside a
smaller addition. The `=` in these defining equations explains computation;
`≡` in your statement is the proposition you must prove.

Use the hints in order to compute `2 + 2` and expand the right-hand `4`,
then build an explicit proof before trying its shorter form. Hints and
**Available building blocks** are available before any Check.

**Check** (`C-c C-l`) finds holes and errors. Select a hole and press
**Goal** (`C-c C-,`) to inspect its required type. Edit the definition and
Check again, or **Give** (`C-c C-SPC`) an expression for the selected hole.
No holes and no errors means solved.

<!-- @conclusion -->
You have seen two proofs: one states the normalized equality explicitly;
the other asks `refl` to prove the original equality directly. Both work
because the two endpoints compute to the same constructor term. This is
called **definitional equality**. Reflexivity does not prove every equality:
it works here because computation makes the endpoints identical.
