---
example_explanation: |-
  1. Expand the two additions on their numeric right arguments.
  2. Both sides become `succ (succ n)`.
  3. `rfl` checks this directly. The exercise has a longer numeral but uses the same rule.
hints:
- hidden: false
  text: The definitions can establish equality even when a variable remains.
- hidden: true
  text: MyNat addition computes on its second argument. Reduce the numerals on the
    right of each addition.
- hidden: true
  text: Compare the two normal forms, then replace `sorry` with the tactic for definitional
    equality.
learning_goals:
- The definitions can establish equality even when a variable remains.
- MyNat addition computes on its second argument. Reduce the numerals on the right
  of each addition.
title: Computation under nested addition
---
The definitions can establish equality even when a variable remains.

MyNat addition computes on its second argument. Reduce the numerals on the right of each addition.

Edit the indented proof directly in the editor. **Check** (`C-c C-l`) checks your current text. Put the cursor on the proof and use **Goal** (`C-c C-,`) to inspect the local context. Replace `sorry` with proof steps; a proof containing `sorry` is unfinished.

<!-- @conclusion -->
You have used this principle in Lean: The definitions can establish equality even when a variable remains. Keep the technique from the worked example in mind when the surrounding expressions change.
