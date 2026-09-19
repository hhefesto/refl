---
learning_goals:
  - "Read MyNat numerals as zero and successors."
  - "Compute addition using its second argument."
  - "Use change to expose the equality before rfl proves it."
hints:
  - text: "Start by unfolding addition and expanding both endpoints. `(2 : MyNat)` is `succ (succ zero)` and the right-hand `4` is `succ (succ (succ (succ zero)))`. Inspect the second argument of `+`."
    hidden: true
  - text: "The left endpoint reduces as `2 + succ (succ zero)` → `succ (2 + succ zero)` → `succ (succ (2 + zero))` → `succ (succ 2)`. The first two steps use the successor rule; the last uses the zero rule."
    hidden: true
  - text: "Expanding the remaining `2` gives `succ (succ (succ (succ zero)))`, exactly the right endpoint's expansion. The equality proposition still asks for a proof, even though computation has made its endpoints identical."
    hidden: true
  - text: |-
      Make the computation explicit in the proof block:

      ```lean
        change (2 : MyNat) + succ (succ zero) = succ (succ (succ (succ zero)))
        change succ ((2 : MyNat) + succ zero) = succ (succ (succ (succ zero)))
        change succ (succ ((2 : MyNat) + zero)) = succ (succ (succ (succ zero)))
        change succ (succ (2 : MyNat)) = succ (succ (succ (succ zero)))
        change succ (succ (succ (succ zero))) = succ (succ (succ (succ zero)))
        rfl
      ```

      Each `change` replaces the goal with one that computes to the same proposition; it does not assume a new fact. `(2 : MyNat)` explicitly selects our number type. The final `rfl` proves equality of identical terms. Paste the indented block into the editor; `by` is already in the fixed statement.
    hidden: true
  - text: |-
      Now try the short proof:

      ```lean
        rfl
      ```

      The checker performs all the same reductions automatically. Replace the editor block and press **Check**.
    hidden: true
example_explanation: |-
  This example asks about `3 + 1`, a different sum. Expand `1` to `succ zero`:

  ```text
  (3 : MyNat) + 1
  → (3 : MyNat) + succ zero
  → succ ((3 : MyNat) + zero)
  → succ (3 : MyNat)
  → succ (succ (succ (succ zero)))
  ```

  The middle steps use the successor and zero rules. In the last step `3`
  expands to three successors of `zero`. Independently, the right-hand `4`
  expands to `succ (succ (succ (succ zero)))`. The example's `change` states
  that normalized goal explicitly; `rfl` proves it. Removing `change` leaves
  the short proof, which lets Lean perform the same computation.
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
of **tactics**, instructions that construct a proof. The editor's `sorry`
is a placeholder; the game counts it as unfinished.

First compute with the game's addition. Its actual definition is:

```lean
def add : MyNat → MyNat → MyNat
  | m, zero => m
  | m, succ n => succ (add m n)
```

`+` uses this `add`. The arrows in its type mean it takes two natural
numbers and returns a natural number. Each `|` starts a case and `=>`
introduces its result. `m` and `n` stand for arbitrary numbers. It inspects
its **second argument**: adding zero returns `m`; adding a successor
puts `succ` around a smaller addition.

Use the hints in order to expand both endpoints and build the explicit
proof, then try the short proof. **Available building blocks** explains the
notation and proof instructions before any Check.

Edit the block and **Check** (`C-c C-l`). To inspect a goal at a particular
step, put the cursor there and press **Goal** (`C-c C-,`).

<!-- @conclusion -->
The expanded proof used `change` to display the computation before `rfl`.
The short proof lets the checker perform that computation automatically.
Both rely on **definitional equality**: the endpoints compute to identical
terms. Reflexivity works for those equalities, not for every proposition.
