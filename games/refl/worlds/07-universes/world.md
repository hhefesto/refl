---
id: universes
title: "Universes"
dependencies: [logic]
options:
  agda: ["--safe", "--without-K"]
  lean: []
---
`Set`, `Set₁`, `Level`, `_⊔_`, `Lift`, `private variable ℓ`. Why `Set : Set` is inconsistent, how level polymorphism is written, and the two tricks the target code uses: `Lift` in `Attention/Linear.agda` and the monomorphic `⊥`/`⊤` of `Misc.lagda`.

*Planned world: the levels below have their learning goals written; statements, hints and solutions are the next authoring pass.*
