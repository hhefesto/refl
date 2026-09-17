---
id: ad
title: "Automatic Differentiation"
dependencies: [records]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
`AdditiveMap` with laws, `Dual`, `D A B = A → B × Dual`, `composeD`/`pairD` via nested `with`, the chain and pairing laws (`refl` only after re-scrutinising `with`), `batchD` and the micro-batch pullback. `AD/Reverse.agda`, `AD/Batch.agda`, and *The Simple Essence of AD*.

*Planned world: the levels below have their learning goals written; statements, hints and solutions are the next authoring pass.*
