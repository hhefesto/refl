`Nat` is the type of natural numbers. `Zero{}` is zero; `Succ{n}` is its
successor, one more than `n`. Braces contain constructor fields; zero has
none. Natural numerals have suffix `n`: `2n` expands to `Succ{Succ{Zero{}}}`.
