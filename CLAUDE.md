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
  `Widgets.LevelPage`, `WorldMap`, `Inventory`, `Donate` (the support page);
  `Widgets.InputTable` is generated.
- `donations.json` at the root is the one place a donation address is
  written: `Widgets.Donate` fetches it, the `website` derivation turns it
  into `qr/<chain>.svg` with `qrencode`, and `refl-check-donations`
  (`Refl.Donations`) re-derives every checksum.
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
- `_≡⟨⟩_` asserts only that the terms around it are definitionally equal; it
  is not one reduction step, so a chain may skip as many rungs as it likes and
  a hole in a *rung* asks for a term (`?0 : ℕ`), not a proof.
- Lean's meet-in-the-middle is core `conv`: `conv => lhs` / `conv => rhs` plus
  `change` restates one endpoint, and when both sides reach the same term
  `conv` closes the goal with no `rfl` typed. Several `change` lines may be
  stacked in one `conv` block, each walking that side one restatement further.
  That auto-close needs *syntactic* agreement (reducible transparency), not
  mere definitional equality: `conv => lhs; change succ 1 + succ 1` against
  `conv => rhs; change succ 3` still reports `unsolved goals`. So Lean's two
  sides must land on the same term, while an Agda `≡⟨⟩` chain's rungs need only
  be definitionally equal and may be spelled differently.
  `conv_lhs`/`conv_rhs` are
  Mathlib and are not available here (`unknown tactic`). `?_` cannot stand for
  a term in `calc` or `show`: it is a *synthetic opaque* metavariable, closed
  to unification, so a neighbouring `rfl` may not solve it (`rfl has type
  ?m = ?m but is expected to have type ?m = succ 3`). An ordinary `_` there
  compiles but is solved silently, so it is no use as a hole. `calc` therefore
  carries proof holes only, and it has no empty justification slot the way
  `≡⟨⟩` does — every rung must spell out `:= rfl`.
- Bend rewrites the other way round from `rw`: `%e : P` with `e : a == b`
  takes `P` = the goal with `_` marking `b`, and leaves `P` with `a` there.
  `%{{==} : {m == lhs : T}} : {_ == rhs : T}` therefore restates one side, the
  closest Bend has to `conv`.
  Base has only `Equal.sym`/`trans`/`cong`. The game's `Refl.step` and
  `Refl.arrive` helpers check computational paths; `Refl.meet` joins two
  paths at a common endpoint using symmetry and transitivity. The first
  lesson teaches these paths and offers native `%` rewrites after completion.
- The donation addresses are checked by `checks.donations`, never by eye.
  BTC (`bc`) and ADA (`addr`) are bech32 (polymod 1); Midnight
  (`mn_shield-addr`) is **bech32m** (polymod 0x2bc830a3), so a uniform
  bech32 test rejects it. Solana is base58, *not* base58check: it decodes to
  exactly 32 bytes and carries no checksum at all, so what actually guards it
  is that the address is written twice — `cnAddress` and the tail of `cnUri`
  — and must agree. The ETH address is all-lowercase, which makes EIP-55
  vacuous on it, so only the shape is checked. `haskellPackages.bech32` and
  `keccak` are both broken in this pin; that is why `Refl.Donations` spells
  the polymod out.
- `qrencode -t SVG -m 4` keeps the spec's four-module quiet zone (`-m 1`
  scans badly on phones), and the QR tile stays white in both themes because
  an inverted QR often will not scan — the one place a literal colour is
  correct rather than a token.
- Only braces annotate in Bend: `{e : T}` is checked, `(e : T)` is the
  operator-namespace marker and its type term is silently discarded when no
  `.method` was parsed, so a wrong type there still prints `All terms check.`
  (`parse_term_tup`/`parse_term_ns` in `bend2/bend.ts`). Annotations nest:
  `{{e : T1} : T2}` checks both layers.

## Rules

- Every Agda level runs `--safe`; `Refl.Nat`/`Refl.Eq`/`Refl.Logic` are the
  game's own so lemmas cannot be imported before they are earned. Worlds ≥ 6
  switch to agda-stdlib (`Refl.Reading.Core` re-exports the vocabulary).
  The two cannot meet in one Agda session: both bind BUILTIN EQUALITY and
  NATURAL, and Agda rejects the duplicate. So `Refl.Everything` never
  imports `Refl.Reading.Core`, the flake checks it in a second `agda` run,
  and a stdlib level never imports `Refl.Nat`/`Refl.Eq`.
- `restrictedSources` forbids unearned **lemma** names only, so syntax such
  as `≡-Reasoning`'s `begin`/`≡⟨⟩`/`∎` is usable before `trans` is earned
  even though those combinators are defined with it. Tutorial level 1
  ("Meet in the middle") documents computational paths (Agda `begin … ∎`,
  Lean `conv`/`change`, Bend `Refl.step`/`arrive`/`meet`). Level 2 documents
  reflexivity as syntax, so the primitive remains usable in level 1's
  native alternative without advertising the shortcut before it; world 1's
  `+-right-comm` no longer unlocks `≡-Reasoning`.
- Level 1 shows **one computation step at each end and asks for the next one**,
  in every language: Agda's chain scaffolds the `suc 1 + suc 1` and `suc 3`
  rungs around two `?` rungs; Lean stacks two `change`s per `conv` block, the
  first shown and the second the player's; Bend nests an extra `Refl.step`
  waypoint per path above `?left`/`?right`. Lean's own placeholder is
  `change ?_`: `?_` is term syntax and is a parse error on its own line in a
  `conv` block (`unexpected token '?'; expected 'binder_predicate'`), but as
  `change`'s argument it parses, acts as a no-op and leaves the goal open.
  `change _`, `change ?name` and `skip` behave the same way.
  This supersedes the earlier
  "one `change` per side" for Lean. The Agda holes may be spelled differently
  (`suc (suc 1 + 1)` and `suc (suc 2)`); Lean's two must coincide.
- Tutorial is nine levels: 1 "Meet in the middle" and 2 "refl" pose the same
  `2 + 2 ≡ 4`. Their Agda lemmas must differ (`two-plus-two-by-hand` and
  `two-plus-two`) because `renderWorldModule` harvests every level's statement
  and solution into one `Refl/World/Tutorial.agda` with no exclusion flag.
  Lean and Bend are not harvested, so both keep `two_plus_two…` freely.
- After adding Agda levels: `refl-check-levels games/refl --emit-world-modules
  languages/agda`, then check `nix build .#agdaSupport`.
- `nix flake check` must stay green: protocol round-trips, content specs,
  backend spec, every level's solution Solved and template Unsolved (and
  every worked example), the smoke test, the security suite (HTTP/WebSocket
  contract), the browser test. It must not need `/dev/kvm` or bubblewrap:
  the isolated provers are exercised by `nix run .#verify-local`, the real VM
  test by `nix build .#module-test` (olimpo has no `/dev/kvm`: `kvm_amd`
  does not load although the CPU reports `svm`).
- Lesson pages stay optional: the level `.md` is the source of shared prose
  and hints, `levels/NN-id/<lang>.md` overrides fields. Never copy the level
  prose into `agda.md` (it only needs `example_explanation`).
- Deployment facts: `nixosModules.default` (`nix/module.nix`) runs
  `packages.isolated-site` (bubblewrap-wrapped provers: needs `AF_NETLINK`
  and `ProtectKernelTunables = false`); the browser identity cookie follows
  the configured `--origin` (`__Host-refl; Secure` on https or loopback,
  plain `refl` on public http, since browsers drop Secure cookies there);
  the WebSocket handshake needs that exact Origin and a cookie. Drafts are
  debounced 1 s and flushed on Check and on leaving (departure reads the live
  textarea because reactive input processing can lag); hidden hints open at any
  time (user decision, 2026-09-18). The consumer is
  `~/src/etc-nixos-configuration` (input `github:hhefesto/refl`); production
  is xty at https://refl.hhefesto.dev (Cloudflare-proxied, since 2026-09-19).
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
  **Reset** is the exception that proves it: it is not a `CommandId` at all but
  a client action that puts `llTemplate` back for the current language, so it
  is always enabled, never gated by an unlock, and must also write the template
  over the stored draft — otherwise the draft flushed on departure undoes it.
  Adding a button to `.commands` breaks the browser test's two exact row
  assertions (`Check,Goal,Reset` for Lean, `Check,Goal,Give,Reset` elsewhere).
- A lesson must not mention a command its language lacks (`teachingProblems`
  fails CI); a worked example is a different statement, type-checked with the
  earned vocabulary. Hidden hints can be revealed in order before any Check.
- The dropdown only rewrites the hash on a level page; the route owns the
  language, so a switch mounts the page once and opens one prover session.
- The support page is answered in `App.hs` *before* the manifest, so it
  still renders when the backend is down, and it deliberately does not wear
  the level chrome. `header.top a.support` is the only call to action in the
  chrome — it needs its own rule because `.primary` is written
  `button.primary` and does not apply to an `<a>`. The chrome wraps below
  760px, where the language label is visually hidden but still labels the
  select.
- Commits: plain messages, no AI attribution trailers.
