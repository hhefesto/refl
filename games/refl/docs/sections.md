An operator with one argument missing is a function: `(x +_)` is `λ y → x + y`, `(_+ x)` is `λ y → y + x`, `(_* x)` likewise. Typical use: `cong (x +_) p` applies `p` under `x + …`. Lean: `(x + ·)`.
