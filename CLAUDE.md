# The Refl Game — working notes

Haskell, Agda, Lean and Nix only. No JavaScript sources: the client is
reflex-dom cross-compiled with the GHC JavaScript backend; `all.js` is a build
product. Bend 2 is an upstream tool from the store (like `agda` and `lean`),
never TypeScript written or vendored here. Define meanings and laws before code (the level format, the protocol
types and the plugin record are the meanings; the drivers are their
implementations).

## What is where

- `common/protocol` — `Refl.Protocol.Types` (wire ADTs, aeson generic),
  `Manifest` (what the browser gets), `Route` (hash routes), `Graph` (map
  layout). Built by GHC and GHCJS: keep it TH-free.
- `common/content` — the content tree parser. `Regions` (the four `-- @…`
  markers), `Level`/`World`, `Splice` (prefix ++ user ++ suffix and the pure
  static rules), `Refl.Content.buildManifest`.
- `backend` — `Refl.Language` is the plugin record; `Refl.Language.Agda`
  drives `agda --interaction-json` (framing in `Agda/Process.hs`, commands in
  `Agda/IOTCM.hs`, JSON in `Agda/Response.hs`); `Refl.Language.Lean` speaks
  LSP over stdio (`Lean/Rpc.hs`); `Refl.Language.Bend2` runs `bend` per
  check and parses its report; `Refl.Server` is servant + websockets with
  one prover per connection; `Refl.Check` is the content CI and the world
  module generator; `backend/browser` is the headless-Chromium acceptance
  test (CDP over websockets, no Node).
- `frontend` — `App` (router shell), `Client` (XHR + websocket),
  `Widgets.Editor` (textarea + highlight overlay + input method + chords),
  `Widgets.LevelPage`, `WorldMap`, `Inventory`; `Widgets.InputTable` is
  generated.
- `games/refl` — content: `docs/<lang>/` per-language inventory docs;
  `levels/NN-id/<lang>.md` optional lesson pages (each field overrides the
  level's) and `<lang>-example.<ext>` worked examples; the level `.md` stays
  the source of the shared prose and of the Agda hints. `languages/agda` —
  the game's own library plus generated `Refl/World/*.agda`.

## Verified facts (do not re-derive)

- Agda 2.8.0 prints `JSON> ` before reading each command; responses are one
  JSON object per line; a command is complete when the unconsumed tail is
  exactly the prompt. Highlight ranges and interaction-point positions are
  1-based code points, end exclusive. `Cmd_auto` is `Cmd_autoOne` in 2.8.
- In batch mode an unsolved hole is an error; in interaction mode it is a
  goal in `AllGoalsWarnings`. `refl-check-levels` uses interaction mode.
- `~/.agda/libraries` on this machine is stale; the flake generates its own
  `AGDA_DIR`. Agda needs `LC_ALL=en_US.UTF-8` and `LOCALE_ARCHIVE` in the
  sandbox.
- The nix store already has Agda 2.8.0 + stdlib 2.3 (`pkgs.agda.withPackages`)
  and the reflex GHCJS set for `nixpkgs-reflex` = `59e6964…`.
- Bend 2.0.4 (github.com/bendlang/bend, commit 8008146, 2026-09-17) is
  TypeScript run by Bun: no build step, no npm runtime deps, no HVM, no
  flake upstream. The flake takes it as a non-flake input and `bend` is
  `bun ${bend2}/bend2/main.ts` (skipping upstream's launcher, which phones
  home and self-updates). CLI contract: `bend f.bend` checks then runs
  `main`; exit 0 with `All terms check.` (no main) or the program output;
  exit 1 with `Error:` on stderr. A loud hole `?name` prints
  `- expected : <normalised goal>` / `- observed : ?name` / `Context:` /
  `Location:` with whole-file line numbers; a quiet `?TODO` or an unproved
  `law` gives `Error: N TODOs found.`. No JSON, LSP or REPL.
  `Refl.Language.Bend2` is a batch driver over that text: exit 0 → Solved,
  `N TODOs` → Unsolved N, a loud hole → Unsolved with the hole typed, a
  mismatch → Failed with the marked line mapped into the user region. Goal
  on a hole re-runs bend with that hole as the only loud one. Levels must
  not define `main` (bend would run it), import, or use `@unsafe`.
- Bend rewrites the other way round from `rw`: `%e : P` with `e : a == b`
  takes `P` = the goal with `_` marking `b`, and leaves `P` with `a` there.

## Rules

- Every Agda level runs `--safe`; `Refl.Nat`/`Refl.Eq`/`Refl.Logic` are the
  game's own so lemmas cannot be imported before they are earned. Worlds ≥ 6
  switch to agda-stdlib (`Refl.Reading.Core` re-exports the vocabulary).
  The two cannot meet in one Agda session: both bind BUILTIN EQUALITY and
  NATURAL, and Agda rejects the duplicate. So `Refl.Everything` never
  imports `Refl.Reading.Core`, the flake checks it in a second `agda` run,
  and a stdlib level never imports `Refl.Nat`/`Refl.Eq`.
- After adding Agda levels: `refl-check-levels games/refl --emit-world-modules
  languages/agda`, then check `nix build .#agdaSupport`.
- `nix flake check` must stay green: protocol round-trips, content specs,
  backend spec, every level's solution Solved and template Unsolved, the
  smoke test, the browser test.
- A load is Solved only with positive evidence: one goals report, one
  interaction-point list and a checked status. An Error display is the
  whole answer to a failing load; do not demand the goals report then.
- Child processes must not get a closed stdout (`NoStream`): the server
  dies on its banner line. Inherit or redirect to /dev/null.
- Headless Chromium in the nix sandbox needs `FONTCONFIG_FILE`
  (`pkgs.makeFontsConf`) or its renderer aborts in Skia; it also needs a
  settle pause after synthetic DOM events before the next DevTools command,
  and strings must reach it as UTF-8 text, never `BL.unpack` of JSON bytes.
- What a prover can do lives in the plugin (`langCommands`) and travels in
  `LangInfo.liCommands`; nothing else hard-codes language ids for commands.
- A lesson must not mention a command its language lacks (`teachingProblems`
  fails CI); a worked example is a different statement, type-checked with the
  earned vocabulary. Hidden hints are offered only after a failed Check.
- The dropdown only rewrites the hash on a level page; the route owns the
  language, so a switch mounts the page once and opens one prover session.
- Commits: plain messages, no AI attribution trailers.
