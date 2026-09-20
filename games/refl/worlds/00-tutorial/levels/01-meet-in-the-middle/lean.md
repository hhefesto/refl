---
learning_goals:
  - "Read MyNat numerals as zero and successors."
  - "Compute addition using its second argument."
  - "Use `conv` to rewrite one side of an equation at a time."
hints:
  - text: "Take one step from the left. The first `change` in the `lhs` block has already expanded both copies of `2` to `succ 1`; the second is yours, and holds a `?_` until you fill it. The successor rule `m + succ n = succ (m + n)` applies twice to `succ 1 + succ 1` and then the zero rule `m + zero = m` finishes: `succ (succ 1 + 1)` → `succ (succ (succ 1 + zero))` → `succ (succ 2)`."
    hidden: true
  - text: "Now take one step from the right. The first `change` in the `rhs` block has already peeled `4` down to `succ 3`; the second is yours, and holds a `?_` until you fill it. Expanding `3` to `succ 2` gives `succ (succ 2)`."
    hidden: true
  - text: "Both sides must arrive at the *same* term, not merely at the same number: `conv` closes the goal only when the two sides read alike. So write `succ (succ 2)` into both of your `change` lines. This is where Lean is stricter than Agda's `≡⟨⟩` chain, whose two holes may be spelled differently."
    hidden: true
  - text: |-
      Point each second `change` at the meeting point:

      ```lean
        conv =>
          lhs
          change succ 1 + succ 1
          change succ (succ 2)
        conv =>
          rhs
          change succ 3
          change succ (succ 2)
      ```

      Once both sides read the same term, `conv` finishes the goal by itself — there is nothing left to prove. Replace the editor block with this and press **Check**.
    hidden: true
example_explanation: |-
  This example asks about `3 + 1`, a different sum, so the endpoints meet
  by a different computation. On the left, `(3 : MyNat) + 1` is `3 + succ zero`, which
  the successor rule turns into `succ (3 + zero)` and the zero rule into
  `succ 3`. On the right, `4` peels to `succ 3` directly. Both `conv` blocks
  therefore aim at `succ 3`, and the goal closes as soon as they agree. One
  `change` per side is enough here; the exercise's sum is further apart, so it
  shows a first step in each block and leaves you the second.
---
Natural numbers start at `zero`; `succ n` is the **successor** of `n`, one
more. This game uses its own number type, `MyNat`. The notation
`(2 : MyNat)` says that `2` has that type, rather than Lean's ordinary `Nat`.

```text
0 = zero
1 = succ zero
2 = succ (succ zero)
4 = succ (succ (succ (succ zero)))
```

These are explanations of numeral notation, not lines to paste into the
proof. Parentheses group function arguments.

The statement after the theorem's colon, `(2 : MyNat) + 2 = 4`, is an
**equality proposition**. It asks for a proof that its endpoints are equal;
it is not itself a proof. After `:= by`, Lean expects an indented sequence
of **tactics**, instructions that construct a proof.

First compute with the game's addition. Its actual definition is:

```lean
def add : MyNat → MyNat → MyNat
  | m, zero => m
  | m, succ n => succ (add m n)
```

`+` uses this `add`. Each `|` starts a case and `=>` introduces its result.
It inspects its **second argument**: adding zero returns `m`; adding a
successor puts `succ` around a smaller addition.

Now **meet in the middle**. Lean lets you work on one endpoint at a time.
A `conv` block focuses the goal: `lhs` selects the left-hand side, `rhs` the
right, and `change` replaces whatever is in focus with a term that
**computes to the same thing**. Several `change` lines in one block walk that
side along, one restatement after another. The editor starts you one step
along each walk and asks you for the next one:

```lean
  conv =>
    lhs
    change succ 1 + succ 1   -- one step from the left, done for you
    change ?_                -- replace the hole: your step from the left
  conv =>
    rhs
    change succ 3            -- one step from the right, done for you
    change ?_                -- replace the hole: your step from the right
```

The first `change` in each block has already taken a step: the left side is
restated with both numerals expanded, the right side with one successor peeled
off `4`. The second `change` in each block is yours. `?_` is Lean's hole: it
stands where a term belongs, changes nothing while it is there, and leaves the
goal open until you write the term yourself. `change` refuses anything that does
not compute to the side it is replacing, so a wrong guess is reported rather
than believed.

**This is laid out differently from the Agda chain.** There, the whole proof is
one column read top to bottom: the left endpoint walks *down* the page, the
right endpoint walks *up* it, and they meet somewhere in the middle. Lean has no
such column. Each `conv` block is a separate walk, and both of them run
**downwards**: the last `change` in the `lhs` block is where the left side ends
up, and the last `change` in the `rhs` block is where the right side ends up.
Nothing meets in the middle of the text — what has to coincide is the **last
line of one block with the last line of the other**.

`conv` is also stricter than `≡⟨⟩` about what "coincide" means. An Agda chain
only asks that adjacent rungs be definitionally equal, so its two holes may be
spelled differently; `conv` closes the goal only once the two sides read the
**same term**. So both of your steps land on that one term, and the proof is
done.

Edit the block and **Check** (`C-c C-l`). To inspect the goal at a particular
point, put the cursor there and press **Goal** (`C-c C-,`).
**Available building blocks** explains the notation before any Check.

<!-- @conclusion -->
You brought `2 + 2` down and `4` up until both read the same term, and
the goal closed with nothing left to prove. That is **definitional equality**:
two terms the checker can see are the same by computing. The tactics construct
the proof, which Lean's kernel checks.

Which raises a fair question. If Lean was willing to compute that far inside
every `change`, why did you have to write the middle at all? The next level
asks the very same thing — `(2 : MyNat) + 2 = 4` — and answers it in one word.
