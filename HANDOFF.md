# Handoff — The Refl Game (2026-09-17, late)

Repo: `~/src/refl` (own git history, clean tree at the commit that adds this
file). Read this, then `CLAUDE.md` (rules and verified facts), then
`README.md` (how to run, develop, author a level).

## Where things stand

Done and green (`nix flake check` passes: website, unit suites, check-levels
with 53 levels, smoke, browser, bend):

- Worlds 0–4 (45 levels) playable in Agda; Tutorial (8 levels) also in Lean 4.
- Headless-Chromium acceptance test (`backend/browser/Main.hs`, `checks.browser`)
  plays the Tutorial through the real UI.
- Bend 2.0.4 packaged: flake input `bend2` (non-flake source), `bend` wrapper
  (`bun ${bend2}/bend2/main.ts`), `nix run .#bend -- f.bend`, `bend` in the dev
  shell, `checks.bend` pins the CLI contract.

- The **Bend 2 game plugin**: the Tutorial is playable in Bend 2. Verified by
  `cabal test all` (24 + 6 + 29 examples), `refl-check-levels --lang bend2`
  (8 checks, 0 failed), the full flake check, and a websocket session on
  Tutorial levels 1 and 6 (Check lists the typed hole, Goal shows type and
  context, Give `{==}` solves level 1 and records progress, a wrong Give
  fails on the right line, a `main` is rejected). Not yet exercised in a
  browser; the browser test still plays Agda only.

## The Bend 2 plugin, file by file

- `backend/src/Refl/Language/Bend2.hs` — the driver (replaces the stub).
  Batch: per Check, write `Level.bend` in a session dir (support `.bend` files
  copied next to it), run `bend Level.bend` under a 60 s timeout with
  `HOME`/`BEND_LIB` inside the session dir, parse the text report
  (`parseBendReport`), build the result (`reportResult`). Commands: Check,
  Goal, Give. Goal re-runs bend with the chosen hole as the only loud `?name`
  (others rewritten to `?TODO`) so bend prints that goal. Give replaces the
  hole span; the server re-checks.
- `backend/src/Refl/Language.hs` — `Env` gains `envBend`, `envBendPath`.
- `backend/src/Refl/Config.hs`, `backend/app/Main.hs` — `--bend PATH`,
  `--bend-path DIR`, env `REFL_BEND`, `REFL_BEND_PATH`.
- `backend/app-check/Main.hs`, `backend/src/Refl/Check.hs` — same flags plus
  `--skip LANG` (repeatable); `checkGame` takes a skip list. The sandboxed
  `check-levels` now passes `--skip lean` (no `/etc/localtime`) instead of
  `--lang agda`, so Bend levels are checked in CI.
- `common/content/Refl/Content/Splice.hs` — `bendRules`: reject a `def`/`law`
  named `main` (bend would run it), any `import` (foreign C/JS bodies, hub
  packages), `@unsafe`. Tests in `common/content/test/Spec.hs`.
- `backend/test/Main.hs` — `describe "bend report"`: report parsing, hole
  scanning (`holesIn`), line-to-span mapping, verdicts.
- `languages/bend2/Refl.bend` — the prelude copied next to every level: own
  `add` recursing on the second argument (so `add(0n, x) == x` needs induction,
  as in Agda). `nix build .#bendSupport` type-checks it (verified: "All terms
  check.").
- `games/refl/worlds/00-tutorial/levels/0N-*.bend` (8 files) — Tutorial in
  Bend. Markers `# @prelude … # @solution`; statement = the `law`, template =
  a `def` whose body is a loud `?goal` (level 8 has `?goal1`, `?goal2`).
  Every solution was run by hand through `bend` and checked before being
  written (the level-4 rewrite motive is `{Refl.add(x, 2n) == 2n+_ : Nat}`).
- `games/refl/worlds/00-tutorial/levels/0N-*.md` — `bend2:` lemma spellings
  (`{==}`, `Equal.cong`, `zero_add`, `Equal.sym`, `Equal.trans`).
- `games/refl/docs/rewrite.md` — the Bend `%e : P` paragraph (direction!).
- `flake.nix` — `bendSupport` derivation; `--bend/--bend-path` threaded into
  `site`, `check-levels` (package and app), `smoke`; `REFL_BEND_PATH` in the
  dev shell; description string.
- `README.md`, `CLAUDE.md`, `languages/bend2/README.md`, `games/refl/game.md`
  — docs updated for the plugin.

## How to re-verify

```sh
cd ~/src/refl && nix develop
cabal build all && cabal test all                  # 24 + 6 + 29 examples
cabal run -v0 refl-check-levels -- games/refl --lang bend2 \
  --bend "$REFL_BEND" --bend-path "$REFL_BEND_PATH"   # 8 checks, 0 failed
git add -A && nix flake check -L                   # flake sees tracked files only
```

To play one Bend level by hand: `cabal run refl-server -- --dev --www
result-website --bend "$REFL_BEND" --bend-path "$REFL_BEND_PATH" …` (see
README), open http://127.0.0.1:8090, choose "Bend 2" in the header dropdown,
Tutorial level 1: Check → hole `?goal : {4n == 4n : Nat}` listed → Goal →
type `{==}` → Give → Solved. Or extend `backend/browser/Main.hs` to do it.

Known shapes, in case something regresses:

- `reportResult` counts goals as `max (bend's number) (holes scanned in the
  user text)`; a template with a loud hole must come back `Unsolved n`, n > 0,
  or `refl-check-levels` rejects it.
- Line mapping: bend's listing line `N>|` is whole-file; user line =
  `N − 1 − count '\n' (lsPrefix)`.
- Level 8's `law analog1_` (a law used as a function signature) and the
  `for -h: Nat -> Nat` quantities were verified by hand with the same shapes.
- The frontend maps `bend2` to input method `"none"` (`liInputMethod'` in
  `frontend/src/Widgets/LevelPage.hs`), which also hides the chord strip.
  Bend syntax is ASCII, so that is intended.

Commit message shape: plain, descriptive; this session's harness appended
`Co-Authored-By`/`Claude-Session` trailers, which contradicts the CLAUDE.md
line "no AI attribution trailers" — the user has not ruled on it.

## After that: the real work

1. **Worlds 5–18** are skeleton `.md` files (learning goals only). Author
   them per `README.md` "Authoring a level"; after adding Agda levels run
   `cabal run refl-check-levels -- games/refl --emit-world-modules languages/agda`
   and rebuild `agdaSupport`. The curriculum, coverage table and world DAG
   are in `~/.claude/plans/i-want-something-like-temporal-kazoo.md`'s history
   (git log of that file) and in `games/refl/worlds/*/world.md`.
2. Bend levels for worlds 1–4 (Addition, Multiplication, Logic, Equality):
   the Tutorial shows the shapes. Cross-level lemma reuse in Bend has no
   generated `Refl.World.*` yet; either extend `Refl.bend` per world or add a
   Bend twin of `emitWorldModules` (`backend/src/Refl/Check.hs`).
3. Lean levels for worlds 1–4.

## Pitfalls that cost time this session

- `fuser` does not exist in this shell; `pkill -f PATTERN` matches your own
  shell's command line (use `pkill -f 'refl-serv[e]r'`); stale
  `refl-server`s held ports and served old content.
- The flake sees only git-tracked files: `git add -A` before `nix build`.
- Chromium in the nix sandbox needs `FONTCONFIG_FILE`; a synthetic DOM event
  followed by the next DevTools command in the same round trip outruns the
  reflex app (the test `settle`s 150 ms); never `BL.unpack` JSON bytes into
  `Text`.
- `Refl.Reading.Core` (stdlib) can never be in the same Agda session as
  `Refl.Eq`/`Refl.Nat` (duplicate BUILTIN bindings): it is checked in a
  second `agda` run, not from `Refl.Everything`.
- A child process launched with a closed stdout (`NoStream`) dies on its
  first print.
- Bend: `%e : P` marks the equation's **right-hand** side with `_`; a `def
  main` is executed, so levels must forbid it; bend reports only the first
  error, so one loud hole at a time.

The user's Chrome extension has never been connected; the browser test is the
real-browser evidence. Session memory for Claude lives in
`~/.claude/projects/-home-hhefesto-src-conal-elliott/memory/refl-game-project.md`.
