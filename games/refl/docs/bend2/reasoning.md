Build two computation paths with ordinary checked functions:

- `Refl.step(current, middle, rest)` keeps a current term visible. The next
  path must start at a term definitionally equal to it and end at `middle`.
- `Refl.arrive(middle)` finishes a path at its own endpoint.
- `Refl.meet(a, b, middle, left, right)` composes a path from `a` to the
  middle with the reverse of a path from `b` to that same middle.

Each nested step can show one or several reductions. For example, a path from
`2n` to `Succ{1n}` can be written as
`Refl.step(2n, Succ{1n}, Refl.arrive(Succ{1n}))`.
The checker rejects `Refl.step(3n, Succ{1n}, Refl.arrive(Succ{1n}))`.
The helper cannot turn an arbitrary number into the chosen middle.

`left = …` binds a local proof. `{expression : Type}` is a checked annotation;
use braces for it. Function calls use parentheses and comma-separated arguments.
The completed lesson also presents Bend's native rewrite alternative.
