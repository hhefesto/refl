---
learning_goals:
  - "Read Nat numerals as Zero{} and successors."
  - "Compute Refl.add using its second argument."
  - "Distinguish an equality type from its reflexivity proof."
hints:
  - text: "Start by unfolding addition and expanding both endpoints. `2n` is `Succ{Succ{Zero{}}}` and the right-hand `4n` is `Succ{Succ{Succ{Succ{Zero{}}}}}`. Inspect the second argument of `Refl.add`."
    hidden: true
  - text: "The left endpoint reduces as `Refl.add(2n, Succ{Succ{Zero{}}})` → `Succ{Refl.add(2n, Succ{Zero{}})}` → `Succ{Succ{Refl.add(2n, Zero{})}}` → `Succ{Succ{2n}}`. The first two steps use the successor case; the last uses the zero case."
    hidden: true
  - text: "Expand the remaining `2n`: the left endpoint is `Succ{Succ{Succ{Succ{Zero{}}}}}`, exactly the right endpoint's expansion. `{a == b : Nat}` is the equality type asking for a proof. It is distinct from the proof `{==}`."
    hidden: true
  - text: |-
      State the normalized equality as the type of the proof:

      ```bend
      def two_plus_two():
        ({==} : {Succ{Succ{Succ{Succ{Zero{}}}}} == Succ{Succ{Succ{Succ{Zero{}}}}} : Nat})
      ```

      `(proof : Type)` is a type annotation: it asks Bend to check that the proof has that type. The outer colon gives the type of `{==}`; the inner `: Nat` says the endpoints are natural numbers. `{==}` proves reflexivity of identical terms. The original law accepts this proof because its endpoints compute to these terms. The `def` supplies the proof for the `law` of the same name.
    hidden: true
  - text: |-
      Now try the short proof:

      ```bend
      def two_plus_two():
        {==}
      ```

      The checker performs all the same reductions automatically. Edit the definition and **Check**, or select the checked hole and **Give** `{==}` in the expression box.
    hidden: true
example_explanation: |-
  This law asks about `3n + 1n`, a different sum. Expand `1n` first:

  ```text
  Refl.add(3n, 1n)
  → Refl.add(3n, Succ{Zero{}})
  → Succ{Refl.add(3n, Zero{})}
  → Succ{3n}
  → Succ{Succ{Succ{Succ{Zero{}}}}}
  ```

  The middle steps use the successor and zero cases. The last expands `3n`
  to three successors of `Zero{}`. Independently, the right-hand `4n`
  expands to `Succ{Succ{Succ{Succ{Zero{}}}}}`. The example annotates `{==}`
  with this normalized equality type. Removing the annotation leaves the
  short proof, letting Bend perform the same computation.
---
Natural numbers count **successors** from zero. Bend's type is `Nat`,
`Zero{}` is zero, and `Succ{n}` is the successor of `n`, one more.
Braces hold a constructor's fields; `Zero{}` has no fields.
The suffix `n` marks natural-number numerals:

```text
0n = Zero{}
1n = Succ{Zero{}}
2n = Succ{Succ{Zero{}}}
4n = Succ{Succ{Succ{Succ{Zero{}}}}}
```

These lines explain notation; they are not editor code.

The fixed `law` states `{Refl.add(2n, 2n) == 4n : Nat}`.
In general, **`{a == b : Nat}` is an equality type**: a proposition saying
that the natural numbers `a` and `b` are equal. It is distinct from a proof
of that proposition. The matching `def` supplies the proof; `?goal` is a
hole where it is missing. The parentheses in `def two_plus_two()` indicate
that this definition takes no arguments; the colon starts its indented body.

Compute first. This is the actual definition in the game's `Refl` module:

```bend
def add(a, b):
  match b:
    case 0n:
      a
    case 1n+p:
      1n+add(a, p)
```

`Refl.add(a, b)` calls that definition. `match b` inspects the **second
argument**. `0n` is `Zero{}`. The pattern `1n+p` is a successor with
predecessor `p`; the result `1n+add(a, p)` is `Succ{add(a, p)}`.
Thus the rules are `Refl.add(a, Zero{})` → `a` and
`Refl.add(a, Succ{p})` → `Succ{Refl.add(a, p)}`.

Use the hints in order to expand both endpoints and build an explicitly
typed proof before trying the shorter proof. **Available building blocks**
is also available before any Check.

**Check** (`C-c C-l`) reports holes with their normalized types. Select a
hole and press **Goal** (`C-c C-,`) to inspect it. Edit and Check again,
or **Give** (`C-c C-SPC`) an expression for the selected hole.

<!-- @conclusion -->
`{==}` is the **reflexivity proof**, not the equality type `{a == b : Nat}`.
Both the annotated and short proof work because the endpoints compute to
identical terms. This is **definitional equality**; reflexivity works here
because of that computation.
