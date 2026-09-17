---
id: iff
index: 9
title: "If and only if"
learning_goals:
  - "`A ⇔ B` is a record of two functions, `to` and `from`."
  - "Reusing earlier lemmas as record fields."
unlocks:
  lemmas:
    - name: "×-swap-⇔"
      agda: "×-swap-⇔"
      lean: "And.comm"
hints:
  - text: "The constructor is `mk⇔`. Both directions are `×-comm`."
    hidden: true
---
`_⇔_` packages an implication each way. Its constructor is `mk⇔`, its
fields `to` and `from`. Build `A × B ⇔ B × A` from your inventory.

<!-- @conclusion -->
The standard library's `Function.Bundles` has the same `mk⇔`/`to`/`from`
(and `Inverse`/`mk↔` for isomorphisms, which the language paper uses
everywhere). World 10 maps those names.
