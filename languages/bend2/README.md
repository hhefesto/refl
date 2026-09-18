# Bend 2 in The Refl Game

Bend 2.0.4 (github.com/bendlang/bend) is a flake input (`bend2`, source only:
upstream is TypeScript run by Bun, has no build step and no flake). The
flake's `bend` package runs `bun <bend2>/bend2/main.ts`, which finds
`base.bend` and `guide/GUIDE.md` relative to itself; calling the interpreter
directly skips upstream's launcher (telemetry, self-update).

```sh
nix run .#bend -- file.bend          # check, then run main
nix run .#bend -- guide | less       # the language guide
bend file.bend                       # inside `nix develop`; $REFL_BEND, $REFL_BEND_PATH
```

## This directory

`Refl.bend` is the game's prelude: its own `add` (recursion on the second
argument, like the Agda levels, so `add(0n, x) == x` needs induction). The
driver copies every `.bend` file here next to each session's `Level.bend`, so
level preludes say `import ./Refl.bend as Refl`. `nix build .#bendSupport`
type-checks them.

## The driver (`Refl.Language.Bend2`)

A batch plugin: each Check writes the spliced level and runs `bend Level.bend`
(60 s timeout, `HOME`/`BEND_LIB` inside the session directory), then reads:

- exit 0, `All terms check.` → Solved;
- `Error: N TODOs found.` → Unsolved N (quiet `?TODO` holes or an unproved `law`);
- a loud hole (`- observed : ?name`) → Unsolved, the hole listed with its
  `- expected :` type and the `Context:` entries;
- `- expected : … / - observed : …` at a `N>|` line → Failed, the line mapped
  into the player's region;
- anything else → Failed with bend's text.

Commands offered: Check, Goal, Give. Goal re-runs bend with the chosen hole
as the only loud one (the others become `?TODO`), so bend prints exactly that
goal. Give replaces the hole's text; the server re-checks. Static rules reject
`main` (bend runs it), `import` (foreign C/JS bodies, hub packages) and
`@unsafe`, plus the lemma names not yet earned.

## Writing a level

```
# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law zero_add:
  for x: Nat
  {Refl.add(0n, x) == x : Nat}
# @template
def zero_add(x):
  ?goal
# @solution
def zero_add(x):
  match x:
    case 0n:
      {==}
    case 1n+p:
      %zero_add(p) : {1n+Refl.add(0n, p) == 1n+_ : Nat}
      {==}
```

The `law` is the fixed statement, the `def` is the player's. `{==}` is refl,
`Equal.cong`/`Equal.sym`/`Equal.trans` live in Base, `%e : P` rewrites (see
`games/refl/docs/bend2/rewrite.md` for the direction), a recursive call is the induction
hypothesis. Quantities: `-x` erased (only in types), bare `x` used at most
once, `+x` reusable. Lemma spellings go in the level front matter as
`bend2: "…"`.
