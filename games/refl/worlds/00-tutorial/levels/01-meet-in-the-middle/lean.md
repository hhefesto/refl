---
learning_goals:
  - "Read MyNat numerals as zero and successors."
  - "Compute addition using its second argument."
  - "Use `conv` to rewrite one side of an equation at a time."
hints:
  - text: "Walk down from the left first. `(2 : MyNat) + 2` is `2 + succ 1`. The successor rule applies twice, then the zero rule: `2 + 2` → `succ (2 + succ zero)` → `succ (succ (2 + zero))` → `succ (succ 2)`."
    hidden: true
  - text: "Now walk down from the right. Nothing computes there — `4` is notation for a stack of successors, and peeling one off gives `succ 3`."
    hidden: true
  - text: "Compare: `succ (succ 2)` on the left, `succ 3` on the right. `succ 2` is `3`, so they are the same number. Write that number into both `change` lines and the two sides become identical."
    hidden: true
  - text: |-
      Point each `change` at where its own side lands:

      ```lean
        conv =>
          lhs
          change succ (succ 2)
        conv =>
          rhs
          change succ (succ 2)
      ```

      Once both sides read the same term, `conv` finishes the goal by itself — there is nothing left to prove. Replace the editor block with this and press **Check**.
    hidden: true
example_explanation: |-
  This example asks about `3 + 1`, a different sum, so the endpoints meet
  by a different computation. On the left, `(3 : MyNat) + 1` is `3 + succ zero`, which
  the successor rule turns into `succ (3 + zero)` and the zero rule into
  `succ 3`. On the right, `4` peels to `succ 3` directly. Both `conv` blocks
  therefore aim at `succ 3`, and the goal closes as soon as they agree.
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
**computes to the same thing**. The editor starts from that shape:

```lean
  conv =>
    lhs
    change (2 : MyNat) + 2
  conv =>
    rhs
    change 4
```

Both `change` lines are no-ops as written — each restates its own side
unaltered. Your job is to walk them towards each other: put where the left
endpoint lands in the first, where the right endpoint lands in the second.
`change` refuses anything that does not compute to the side it is replacing,
so a wrong guess is reported rather than believed. When the two sides finally
read the same term, `conv` closes the goal on its own and the proof is done.

Edit the block and **Check** (`C-c C-l`). To inspect the goal at a particular
point, put the cursor there and press **Goal** (`C-c C-,`).
**Available building blocks** explains the notation before any Check.

<!-- @conclusion -->
You brought `2 + 2` down and `4` down until both read the same number, and
the goal closed with nothing left to prove. That is **definitional equality**:
two terms the checker can see are the same by computing. The tactics construct
the proof, which Lean's kernel checks.

Which raises a fair question. If Lean was willing to compute that far inside
every `change`, why did you have to write the middle at all? The next level
asks the very same thing — `(2 : MyNat) + 2 = 4` — and answers it in one word.
