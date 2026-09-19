---
title: "If and only if"
learning_goals:
  - "`A ⇔ B` is a record of two functions, `to` and `from`."
  - "Reusing earlier lemmas as record fields."
hints:
  - text: "The constructor is `mk⇔`. Both directions are `×-comm`."
    hidden: true
example_explanation: |-
  1. Read equivalence as two function types.
  2. The forward function adds a trivial proof.
  3. The reverse projection drops it. Use `mk⇔` with the exercise's two appropriately typed functions.
---
`_⇔_` packages an implication each way. Its constructor is `mk⇔`, its
fields `to` and `from`. Build `A × B ⇔ B × A` from your inventory.

<!-- @conclusion -->
The standard library's `Function.Bundles` has the same `mk⇔`/`to`/`from`
(and `Inverse`/`mk↔` for isomorphisms, which the language paper uses
everywhere). World 10 maps those names.
