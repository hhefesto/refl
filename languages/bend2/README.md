# Bend 2 in The Refl Game

Bend 2.0.4 (github.com/bendlang/bend) is a flake input of this repository
(`bend2`, source only: upstream is TypeScript run by Bun, has no build step
and no flake). The flake's `bend` package is a wrapper that runs
`bun <bend2>/bend2/main.ts`, which finds `base.bend` and `guide/GUIDE.md`
relative to itself. Calling the interpreter directly skips upstream's
launcher, which sends telemetry and self-updates.

```sh
nix run .#bend -- --version          # bend 2.0.4
nix run .#bend -- file.bend          # check, then run main
nix run .#bend -- guide | less       # the language guide
nix run .#bend -- base --types       # the prelude's types
bend file.bend                       # inside `nix develop`; $REFL_BEND is the path
```

`checks.bend` (`nix flake check`) pins the contract below against upstream's
own test corpus, so a Bend upgrade that changes it fails CI before the game
does.

## The CLI contract the plugin will rely on

- `bend f.bend`: exit 0 and `All terms check.` on stdout when every `law` has
  a `def` and nothing is left open (if `main` exists it is run and its
  output printed instead); exit 1 and `Error: …` on stderr otherwise.
- A loud hole `?name` fails the check and prints the goal:

  ```
  Error:
  - expected : {4n == 4n : Nat}
  - observed : ?goal
  Context:
  - n : Nat
  Location: two_plus_two
  6 | def two_plus_two():
  7>|   ?goal
  ```

  The expected type is normalised (`Nat.add(2n, 2n)` shows as `4n`), which
  is what a Goal panel wants. Line numbers are whole-file: shift them by the
  prelude's line count, as `Refl.Language.Lean` does.
- A quiet hole `?TODO` type-checks at any goal but the file is refused with
  `Error: N TODOs found.` — the "N goals remaining" signal. An unproved `law`
  (no matching `def`) counts as a TODO too, so a template may be just the
  law.
- A wrong proof reports `- expected : 4n` / `- observed : 5n` at the offending
  line. There is no JSON, LSP or REPL; parse the text above.

## The language, as far as a level needs it

```
import Base

law add_comm:
  for  a: N
  for +b: N
  {add(a, b) == add(b, a) : N}

def add_comm(a, b):
  match a:
    case Z{}:
      %add_zero(b) : {_ == add(b, Z{}) : N}
      {==}
    case S{p}:
      %add_succ(b, p) : {S{add(p, b)} == _ : N}
      %add_comm(p, b) : {S{add(p, b)} == S{_} : N}
      {==}
```

`law` states, `def` proves. `{a == b : T}` is the equality type, `{==}` is
refl, `%e : {… _ …}; body` rewrites with `e` (the `_` marks the side being
replaced), `match`/`case` eliminates, and a structurally recursive call is
the induction hypothesis. Quantities matter: `-x` erased, bare `x` used at
most once, `+x` reusable (needs a `Data` type). Comments are `#`, so level
sources use `# @prelude`, `# @statement`, `# @template`, `# @solution`
(the content layer already maps `bend2` to `.bend` and `#`).

## Plugin checklist (next pass)

Implement `Refl.Language.Language` the way `Refl.Language.Lean` does, as a
batch driver: `langStart` gated on `envBend`, a per-session directory,
`splice` prefix + user text, run `bend` with a timeout via `System.Process`,
map exit code and stderr to `Verdict` with `Refl.Verify.verdictFrom`
(0 → Solved; `N TODOs found` → Unsolved N; a loud hole → Unsolved 1 with the
goal as diagnostic; anything else → Failed). `psHole` can answer `OpGoal`
from the same text. Static rules: no `@unsafe`, no `import` other than
`import Base`. Then thread `--bend`/`REFL_BEND` through `Refl.Config`,
`backend/app/Main.hs`, `app-check/Main.hs`, `packages.site` and
`check-levels`, flip `liAvailable`, and add `.bend` sources next to the
`.agda`/`.lean` ones with `bend2:` spellings in the level front matter.
