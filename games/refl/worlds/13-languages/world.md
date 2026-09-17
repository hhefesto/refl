---
id: languages
title: "Languages as Types (ICFP 2021 capstone)"
dependencies: [logic, coinduction]
options:
  agda: ["--safe", "--guardedness"]
  lean: []
---
`Lang = A✶ → Set ℓ`, the operators, ν/𝒟/δ, `𝒟foldl`, the ν/δ table (half `refl`, half `mk↔`), lifted deciders `_⊎‽_`/`_×‽_`, the contravariant `_◃_`, the indexed `data Lang : ◇.Lang → Set` with isomorphism-as-constructor, the coinductive `record Lang`, `⟦_⟧‽ : Lang P → Decidable P`, and the weighted variant over `IsCommutativeSemiring`.

*Planned world: the levels below have their learning goals written; statements, hints and solutions are the next authoring pass.*
