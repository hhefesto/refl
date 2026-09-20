---
learning_goals:
  - "Read Nat numerals as Zero{} and successors."
  - "Compute Refl.add using its second argument."
  - "Build separate left and right paths to a common middle."
hints:
  - text: "Take one step from the left. The left path already shows one: `Refl.add(2n, 2n)` is `Refl.add(2n, Succ{1n})`, and the successor case gives `Succ{Refl.add(2n, 1n)}`. Your step continues from there — another successor step gives `Succ{Succ{Refl.add(2n, 0n)}}`, which fills `?left`."
    hidden: true
  - text: "Now take one step from the right. The right path already shows one: `4n` expands to `Succ{3n}`. Your step continues from there — expanding `3n` once more gives `Succ{Succ{2n}}`, which fills `?right` and is the middle itself."
    hidden: true
  - text: "Both paths must end at the same number. Read each nested `Refl.step` from the outside inward: the current endpoint, the step shown for you, your step, then `Refl.arrive(middle)`. Every adjacent pair must compute to the same number. You can add more steps to show smaller reductions."
    hidden: true
  - text: |-
      Here are the two completed paths:

      ```bend
      def two_plus_two_by_hand():
        middle = {Succ{Succ{2n}} : Nat}
        left = Refl.step(Refl.add(2n, 2n), middle,
          Refl.step(Succ{Refl.add(2n, 1n)}, middle,
            Refl.step(Succ{Succ{Refl.add(2n, 0n)}}, middle,
              Refl.arrive(middle))))
        right = Refl.step(4n, middle,
          Refl.step(Succ{3n}, middle,
            Refl.step(Succ{Succ{2n}}, middle,
              Refl.arrive(middle))))
        Refl.meet(Refl.add(2n, 2n), 4n, middle, left, right)
      ```

      Select each hole and **Give** its number expression, or edit and **Check**. Change either intermediate term to `3n` and the checker rejects that path, even if the other path is correct.
    hidden: true
example_explanation: |-
  The example proves the different sum `3n + 1n = 4n`. Its left path follows:

  ```text
  Refl.add(3n, 1n)
  → Refl.add(3n, Succ{Zero{}})
  → Succ{Refl.add(3n, Zero{})}
  → Succ{3n}
  ```

  The right path expands `4n` to `Succ{3n}`. `Refl.arrive(middle)` ends each
  path at that common term. `Refl.meet` joins the left path to the reverse
  of the right path, proving the original equality. The exercise's sum is
  further apart, so each of its paths shows a first step and leaves you the
  next one.
---
Natural numbers count **successors** from zero. Bend's type is `Nat`,
`Zero{}` is zero, and `Succ{n}` is the successor of `n`, one more.
Braces hold constructor fields. The suffix `n` marks natural numerals:

```text
0n = Zero{}
1n = Succ{Zero{}}
2n = Succ{Succ{Zero{}}}
4n = Succ{Succ{Succ{Succ{Zero{}}}}}
```

These lines explain notation; they are not editor code.
The fixed `law` states `{Refl.add(2n, 2n) == 4n : Nat}`. In general,
`{a == b : Nat}` is an **equality type**: the proposition that the two natural
numbers are equal. A proof is a value of that type. The matching `def`
supplies the proof; its parentheses mean it takes no arguments.

First compute. This is the game's actual addition definition:

```bend
def add(a, b):
  match b:
    case 0n:
      a
    case 1n+p:
      1n+add(a, p)
```

`match b` inspects the **second argument**. The zero case returns `a`.
`1n+p` matches a successor whose predecessor is `p`; the result is
`Succ{add(a, p)}`. Thus:

```text
Refl.add(a, Zero{})  → a
Refl.add(a, Succ{p}) → Succ{Refl.add(a, p)}
```

Now build **two paths**. One starts at `Refl.add(2n, 2n)`, the other at
`4n`. The proposed meeting point is `Succ{Succ{2n}}`. Each path already shows
its first step and then leaves a hole for the next one. Fill those holes by
computing on from the term shown just above each of them.

The game's small proof library supplies three ordinary, checked functions:

- `Refl.step(current, middle, rest)` adds a term to a path. `rest` must
  start at a term that computes to `current` and end at `middle`.
- `Refl.arrive(middle)` ends the path at the meeting point.
- `Refl.meet(leftStart, rightStart, middle, left, right)` joins the left
  path with the reverse of the right path to prove the original equality.

Read nested `step` calls from the outside inward. The names `left` and
`right` hold the two proofs separately; they are not assertions the checker
blindly trusts. A wrong intermediate number fails even when both paths are
present. A step may cover several reductions; add another `step` if you want
to show a smaller move.

`middle = {… : Nat}` defines a local name. `{expression : Type}` is a checked
**type annotation**, so here the colon says the expression is a natural
number. Function arguments go in parentheses and are separated by commas;
indentation and the closing parentheses show the nesting.

**Check** (`C-c C-l`) reports unfinished holes. Select one and press **Goal**
(`C-c C-,`) to inspect its required type, then **Give** (`C-c C-SPC`) a number
expression, or edit and Check again. The hints and building blocks are
available from the start. After completing the paths, the conclusion shows
how the same demonstration looks using Bend's native rewrite notation.

<!-- @conclusion -->
Both paths reached the same term. The checker verified every computational
step, and `Refl.meet` joined their proofs. This is **definitional equality**:
terms can look different on the page yet become identical by computation.

You can also write this demonstration using **native rewrites**:

```bend
def two_plus_two_by_hand():
  %{{==} : {Succ{Succ{2n}} == Refl.add(2n, 2n) : Nat}} : {_ == 4n : Nat}
  %{{==} : {Succ{Succ{2n}} == 4n : Nat}} : {Succ{Succ{2n}} == _ : Nat}
  {==}
```

`{==}` is Bend's reflexivity proof. The outer `{proof : Type}` annotation
checks each equation. `%proof : P` replaces the marked `_` (the equation's
right-hand endpoint) by its left-hand endpoint in the remaining goal.
Here the first line changes the goal's left side, and the second changes its
right side. The final `{==}` proves equality of the two copies of the middle.
This uses the same checked equality machinery as the named paths, with the
rewrites written explicitly instead of composed by `Refl.meet`.

Try this second approach if you like; both are accepted. In the next lesson
we return to the original equality and discover why a single reflexivity
proof is enough, with no paths or rewrites written out.
