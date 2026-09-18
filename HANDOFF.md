# Handoff — The Refl Game (2026-09-18)

Repo: `~/src/refl` (own git history). Read this, then `CLAUDE.md` (rules and
verified facts), then `README.md` (run, develop, author a level).

## Where things stand

Green at the commit that adds this file (`nix flake check`: website, unit
suites, check-levels over every level and worked example, smoke, bend,
browser):

- Worlds 0–4 (45 levels) playable in Agda; the Tutorial (8 levels) also in
  Lean 4 and in Bend 2.
- Provers: Agda 2.8.0 (`--interaction-json`), Lean 4.30.0 (`--server`), Bend
  2.0.4 (batch `bend` runs; flake input `bend2`, TypeScript on Bun).
- Lessons per language: `levels/NN-id/<lang>.md` (optional, each field
  overrides the level's) and `<lang>-example.<ext>` (a similar problem worked
  out, shown collapsed, type-checked in CI). Docs per language under
  `docs/<lang>/`. The level `.md` stays the source of the shared prose and of
  the Agda hints; the 16 Lean/Bend Tutorial pages carry their own hints.
- Client: dark/light theme (`frontend/src/Theme.hs`), CSS tokens, the route
  owns the language, hidden hints unlock after a failed Check, drafts are
  saved after a 2 s pause and on leaving the page.
- Headless-Chromium acceptance test (`backend/browser/Main.hs`) covers the
  Agda Tutorial, Bend flows (Lean too where the sandbox allows), theme
  persistence, contrast, language routing, drafts, hints, failure and retry.

## What the last two passes did

1. Codex added the per-language lessons, docs split, theme and larger browser
   test, and left the client not booting (committed as found, `45e849b`).
2. Review pass (this commit): lesson pages became optional overrides instead
   of required replacements (the original hand-written level text and hints
   are live again); commands moved from a protocol table into
   `LangInfo.liCommands` fed by each plugin; the router hang was a `holdDyn`
   on an event defined later in the same `mdo` (the dropdown now only follows
   the route, and rewrites the hash on a level page); per-keystroke draft
   saves went back to a debounce; hidden hints are gated again; the
   input-method cheat sheet is back; the `manifest` derivation got the locale
   the non-ASCII doc names need; 14 one-line filler docs and the lemma-name
   fallback were dropped (explicit `doc:` only, placeholder otherwise); 12
   recycled or off-topic Agda worked examples were rewritten as genuinely
   similar problems with "how to start" explanations; the 16 boilerplate
   Lean/Bend pages were rewritten; the Bend rewrite doc got its numeric
   worked example back; `% transport` became `%h : P`.

## How to re-verify

```sh
cd ~/src/refl && nix develop
cabal build all && cabal test all                 # 6 + 29 + 29 examples
cabal run refl-build-manifest -- games/refl -o /tmp/m.json   # authoring laws
cabal run -v0 refl-check-levels -- games/refl --agda "$REFL_AGDA" --agda-dir "$AGDA_DIR" \
  --lean "$REFL_LEAN" --lean-path "$REFL_LEAN_PATH" --bend "$REFL_BEND" --bend-path "$REFL_BEND_PATH"
                                                  # 122 checks (61 exercises + 61 examples), 0 failed
git add -A && nix flake check -L                  # the flake sees tracked files only
nix run                                           # http://127.0.0.1:8090
```

Browser test by hand (screenshots land in `$REFL_BROWSER_ARTIFACTS`):
`cabal run refl-browser-test -- <chromium> <site wrapper> games/refl`, where
the wrapper runs `refl-server` with `--www result-website` and all prover
flags (see `flake.nix` `packages.site`).

## Next

1. **Worlds 5–18** are skeleton `.md` files (learning goals only). Author
   them per `README.md`; after adding Agda levels run
   `cabal run refl-check-levels -- games/refl --emit-world-modules languages/agda`
   and rebuild `agdaSupport`. The curriculum, coverage table and world DAG
   are in `games/refl/worlds/*/world.md` and the plan file's git history.
2. Lean and Bend sources for worlds 1–4 (the Tutorial shows the shapes).
   Bend has no generated per-world modules yet: extend `languages/bend2/Refl.bend`
   per world or add a Bend twin of `emitWorldModules` (`backend/src/Refl/Check.hs`).
3. Worked examples for later worlds are Agda-only; add `lean-example.lean` /
   `bend2-example.bend` alongside the sources when those exist.

## Pitfalls that cost time

- `fuser` does not exist in this shell; `pkill -f PATTERN` matches your own
  shell's command line (use `pkill -f 'refl-serv[e]r'`); stale servers hold
  ports and serve old content.
- The flake sees only git-tracked files: `git add -A` before `nix build`.
- Chromium in the nix sandbox needs `FONTCONFIG_FILE`; after a synthetic DOM
  event the test must `settle` before the next DevTools command; never
  `BL.unpack` JSON bytes into `Text`.
- `Refl.Reading.Core` (stdlib) can never share an Agda session with
  `Refl.Eq`/`Refl.Nat` (duplicate BUILTIN bindings).
- A child process launched with a closed stdout dies on its first print.
- Bend: `%e : P` marks the equation's **right-hand** side; a `def main` is
  executed, so levels forbid it; bend reports only the first error.
- Haskell: `let t = f t` inside a list comprehension is a recursive binding
  and hangs silently. In the reflex client, a `holdDyn` whose event is bound
  later in the same `mdo` hangs the whole widget build with no error in the
  console (the page stays empty); wire such loops through the DOM (hash,
  route) instead.
- DevTools: `Page.addScriptToEvaluateOnNewDocument` is honoured only after
  `Page.enable`; a reload must be followed by a wait for a *new* document
  (the test marks the old one) before polling; the language `<select>` is a
  `selectElement` whose option values are the language ids, on purpose.
- Level `.md` prose is what Agda players read; a `<lang>.md` page is the
  place for Lean/Bend-specific text. Do not duplicate the level prose into
  `agda.md` — it only needs `example_explanation`.

The user's Chrome extension has never been connected; the browser test is the
real-browser evidence. Claude's session memory lives in
`~/.claude/projects/-home-hhefesto-src-conal-elliott/memory/refl-game-project.md`.
