# Bend2 plugin (stub)

Bend2 (github.com/bendlang/bend) is unreleased as of 2026-09-16: the repository
is a "Coming soon" README. `Refl.Language.Bend2` therefore implements the
`Language` plugin record with `liAvailable = False`; selecting it in the UI
shows "not available" and nothing else in the engine assumes Bend2 syntax.

To add it when it ships, implement `Refl.Language.Language` the way
`Refl.Language.Agda` does:

1. `langInfo` — id `bend2`, file extension, input-method table name.
2. `langCommands` — which of `CommandId` the checker can answer.
3. `langStaticRules` — pure checks on the user region (no axioms, no
   unsafe escape hatches).
4. `langStart` — spawn the checker per session, implement `psCheck`
   (splice, run, collect diagnostics/goals → `CheckResult`) and `psHole`.

Then add `.bend` level sources next to the `.agda`/`.lean` ones and register
the plugin in `Refl.Language.Registry`.
