---
learning_goals:
  - "`A & B` is a pair; `(a, b)` builds one."
  - "A destructuring let names its parts."
hints:
  - text: "`(a, b) = p` on one line takes the pair apart. Put `?g` on the next line and press **Goal**. It prints `Sigma<&1, &1, B, _ => A>`, Bend's name for `B & A`."
  - text: "`(x, y)` builds a pair, where the first part proves the left side."
  - text: "`(a, b) = p`, then `(b, a)`."
example_explanation: |-
  1. Take the outer pair apart, then the inner one, to name all three parts.
  2. Read the target's nesting.
  3. Reassemble with `(…, …)`. Use the same decomposition and reassembly in the exercise's different arrangement.
---
To prove "A and B" you need a proof of `A` and a proof of `B`, so a proof of `A & B` is a **pair** of proofs. You build one with `(a, b)`.

To use one, take it apart with a **destructuring let**. It's a line of its own, with the rest of the proof below it:

```
(a, b) = p
```

The statement says "and" is commutative. The `def` names the hypothesis `p`. Take it apart, then build the pair you need.

When you ask for the **Goal**, don't be thrown by what you get: `B & A` is printed as `Sigma<&1, &1, B, _ => A>`. `A & B` is shorthand for that dependent pair type, as you'll see when you get to `exs` in a few levels. Read the `B` and the `A`, and ignore the rest.

<!-- @conclusion -->
A pair of proofs is a pair like any other. `Pair.fst` and `Pair.snd` in Base project out the parts, but a proof usually just takes the pair apart.
