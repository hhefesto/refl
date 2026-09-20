---
id: meet-in-the-middle
index: 1
title: "Meet in the middle"
learning_goals:
  - "Read natural numbers as zero and successors."
  - "Compute addition using its second argument."
  - "Distinguish an equality type from a proof of that type."
  - "Bring both endpoints of an equation to one term."
unlocks:
  commands: [load, goal, give]
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
    - name: "walking one side"
      agda: "begin, ≡⟨⟩, ∎"
      lean: "conv, change"
      bend2: "Refl.step, Refl.arrive, Refl.meet"
      doc: "reasoning.md"
hints:
  - text: "Walk down from the left first. `2 + 2` is `2 + suc (suc zero)`. The successor rule `m + suc n = suc (m + n)` applies twice, then the zero rule `m + zero = m`: `2 + 2` → `suc (2 + suc zero)` → `suc (suc (2 + zero))` → `suc (suc 2)`."
    hidden: true
  - text: "Now walk down from the right. Nothing computes here — `4` is simply notation for a stack of successors, and peeling one off gives `suc 3`."
    hidden: true
  - text: "Compare what you have: `suc (suc 2)` on the left, `suc 3` on the right. `suc 2` is `3`, so these are the same number written two ways. That is where the endpoints meet, and either spelling may go in the holes."
    hidden: true
  - text: |-
      Fill the two holes with where each side landed:

      ```agda
      two-plus-two-by-hand =
        begin
          2 + 2        ≡⟨⟩
          suc (suc 2)  ≡⟨⟩
          suc 3        ≡⟨⟩
          4            ∎
      ```

      Select a hole and **Give** the term, or edit the definition and **Check**. `≡⟨⟩` asks the checker to verify that adjacent terms compute to the same thing; you do not supply a separate proof argument for that step.
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

The fixed statement `two-plus-two-by-hand : 2 + 2 ≡ 4` names a proposition:
`2 + 2 ≡ 4` is an **equality type**, saying the two numbers are equal.
The colon reads “has type”. A proof is a value of that type; the statement
itself is not the proof.

Before proving anything, compute. The game's addition has these two rules:

```agda
m + zero  = m
m + suc n = suc (m + n)
```

Here `m` and `n` stand for any natural numbers. Addition inspects its
**second argument**: zero returns `m`; a successor puts `suc` outside a
smaller addition. The `=` in these defining equations explains computation;
`≡` in your statement is the proposition you must prove.

Now **meet in the middle**. Walk the left endpoint `2 + 2` down by those
rules, walk the right endpoint `4` down by unfolding its successors, and stop
as soon as the two sides read the same term. The editor starts from that
shape:

```agda
two-plus-two-by-hand =
  begin
    2 + 2        ≡⟨⟩
    ?            ≡⟨⟩
    ?            ≡⟨⟩
    4            ∎
```

`begin` opens a chain of terms and `∎` closes it on the last one. Between two
lines, `≡⟨⟩` claims that they **compute** to the same thing — it carries no
explicit proof argument, and it does not have to be a single step, so you may travel as far as
you like between one line and the next. The first hole is where the left
endpoint lands; the second is where the right endpoint lands. Both holes ask
for a **number**, not for a proof, and the whole chain works out only if the
two numbers you write are the same one.

**Check** (`C-c C-l`) finds holes and errors. Select a hole and press
**Goal** (`C-c C-,`) to see what it wants. Edit the definition and Check
again, or **Give** (`C-c C-SPC`) a term for the selected hole. Hints and
**Available building blocks** are available before any Check.

<!-- @conclusion -->
You brought `2 + 2` down and `4` down until both read the same number, and
the chain closed with nothing to prove in between. That is what `≡⟨⟩` means:
the two terms around it are **definitionally equal**, the checker can see it
by computing. The chain functions construct the proof for these computational steps.

Which raises a fair question. If the checker is willing to compute that far
on every line, why did you have to write the middle at all? The next level
asks the very same thing — `2 + 2 ≡ 4` — and answers it in one word.
