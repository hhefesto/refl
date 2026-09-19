# The Refl Game

An [NNG4](https://adam.math.hhu.de/#/g/leanprover-community/nng4)-style game
for learning **Agda** (and Lean 4, and Bend 2): worlds of levels,
each a statement with a hole; you fill the hole until the checker says `refl`.
The curriculum ends where the real code lives — Conal Elliott's `felix`, the
ICFP 2021 language-derivatives development, and the Agda specifications in
`formalTransformer` and `aanalyzer-classic`.

Everything is Haskell and Nix: a servant backend that runs one prover process
per browser session, a reflex-dom client cross-compiled to JavaScript, and a
content tree of Markdown + `.agda`/`.lean` files that is type-checked in CI.

## Run

```sh
nix run                      # http://127.0.0.1:8090
nix flake check              # builds everything, checks every level and worked example, plays the Tutorial in headless Chromium
nix run .#check-levels       # the same, plus the Lean levels (needs /etc/localtime, which the sandbox lacks)
nix run .#bend -- file.bend  # Bend 2 on its own (checks the file, then runs its main); also `bend` in the dev shell
```

`nix run` builds the client bundle (slow the first time: it cross-compiles
reflex-dom with the GHC JavaScript backend; the reflex cache helps).

## NixOS module

Import this flake's `nixosModules.default`, then enable its profile:

```nix
{
  imports = [ inputs.refl.nixosModules.default ];
  services.refl.profile = {
    enable = true;
    backend = { address = "127.0.0.1"; port = 3007; };
    ingress.enable = false;
  };
}
```

Open **http://127.0.0.1:3007** (use this exact origin for WebSockets). The
module runs `refl.service`, keeps browser-specific state in `/var/lib/refl`,
and pins its own Agda, Lean and Bend packages. Without DNS, serve plain http
on the public address instead: `backend = { address = "62.238.6.4"; port = 3007;
openFirewall = true; }` and open **http://62.238.6.4:3007**. With a domain,
set `hostname` and `ingress.enable = true` for nginx and ACME on 80/443 (the
host must already accept the ACME terms). The browser cookie follows the
origin: `__Host-refl; Secure` on https and loopback, a plain `refl` cookie on
public http, because browsers drop Secure cookies there. Each prover sees only its session
directory and read-only tool closure, in isolated process/network namespaces.
Defaults are 2 GiB aggregate memory, no swap, one CPU quota, four sessions,
128 tasks, 256 MiB temporary storage, 64 KiB messages, 120-second commands and
300-second idle sessions. See [the module](nix/module.nix) for typed options.
Ingress is opt-in; local operation needs neither nginx nor PostgreSQL.

The consumer is `~/src/etc-nixos-configuration` (input `github:hhefesto/refl`,
profile blocks for olimpo on loopback and for xty on the public address).
Build as your user and activate with `--sudo` so evaluation keeps your private
Git access:

```sh
nixos-rebuild build --flake ~/src/etc-nixos-configuration#olimpo
nixos-rebuild switch --sudo --flake ~/src/etc-nixos-configuration#olimpo
nix run ~/src/etc-nixos-configuration#deploy-xty      # production, gated
```

A pushed commit is what the consumer sees: bump its `refl` input
(`nix flake lock --update-input refl`) after pushing. See
[the rollout handoff](HANDOFF-ROLLOUT.md).

`nix run .#verify-local` checks isolated proofs, Chromium and HTTP/WebSocket
sessions outside the Nix builder (bubblewrap cannot run inside it; `nix flake
check` covers the same HTTP/WebSocket contract as `checks.security` with the
plain provers). `nix build .#module-test` boots a real VM against the module
(custom names, cgroup limits, tmpfs cap, isolation, OOM recovery) and needs
`/dev/kvm`. The browser harness can also test an already
running module with `REFL_BROWSER_EXISTING_URL=http://127.0.0.1:3007`; in this
mode it never starts or stops the service and skips server restart/retry checks.

## Develop

```sh
direnv allow                 # or: nix develop
cabal build all              # shared packages + backend
cabal test all
cabal run refl-server -- --dev --www frontend/static-dev   # backend on :8090
```

The client can be iterated natively with jsaddle-warp, without the JS build:

```sh
nix develop .#frontend -c cabal --project-file=cabal-frontend.project run frontend-dev   # :3003
```

(the dev runner points at `http://127.0.0.1:8090`; start the backend with
`--dev` so it sends permissive CORS headers). For a real bundle:
`nix build .#website` and serve it with `--www result`.

Lean levels in the dev shell need the support library built once:
`(cd languages/lean && lake build)`.

The browser acceptance test (`checks.browser`) drives headless Chromium over
the DevTools protocol from Haskell, no Node or WebDriver: it plays every
Tutorial level through the real UI, exercises Give, case split, errors,
drafts and the retry path after a server failure. To run it by hand:

```sh
nix build .#site && cabal run refl-browser-test -- $(nix build nixpkgs#chromium --print-out-paths)/bin/chromium result/bin/refl-site games/refl
```

## Layout

```
common/protocol   wire types + manifest + routes (GHC and GHCJS)
common/markdown   commonmark → sanitized HTML
common/content    the games/ tree → manifest and per-level sources
backend/          refl-server, refl-build-manifest, refl-check-levels, refl-gen-input-table, refl-browser-test
frontend/         reflex-dom SPA
games/refl/       the content: game.md, worlds/NN-<id>/world.md, levels/NN-<id>.{md,agda,lean,bend}, docs/
languages/agda    Refl.Nat, Refl.Eq, Refl.Logic, Refl.Bool, Refl.Reading.Core (stdlib vocabulary for the reading levels) and the generated Refl.World.* modules
languages/lean    the lake project with Refl.MyNat
languages/bend2   Refl.bend, the prelude copied next to every Bend level; notes on the Bend 2 driver
```

## Authoring a level

A level is `levels/NN-<id>.md` (front matter + intro + `<!-- @conclusion -->`
+ conclusion) and one source per language, split into four regions:

```agda
-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.PlusComm where
open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
-- @statement
+-comm : ∀ (x y : ℕ) → x + y ≡ y + x
-- @template
+-comm x y = ?
-- @solution
+-comm x zero = sym (zero-+ x)
+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))
```

The prelude and statement are fixed and spliced around the player's text; the
template is what they start from (`.lean` and `.bend` siblings use the same
four markers with their own comment syntax; a Bend template is a `def` whose
body is a loud hole `?goal`); the solution is stripped from the manifest
and checked by `refl-check-levels`. Front matter declares `unlocks` (commands,
lemmas with per-language names, syntax), `forbids`, and `hints` (with
`hidden: true` for the ones revealed on request). Lemma names unlocked by
later levels are automatically forbidden in earlier ones.

Docs live per language under `docs/agda/`, `docs/lean/`, `docs/bend2/`: a
`doc: "refl.md"` in the front matter resolves to `docs/<lang>/refl.md` for
each language, and an inventory item without a doc for the current language
shows a placeholder. Lemma and syntax items carry per-language spellings
(`agda:`, `lean:`, `bend2:`).

A level may add a directory `levels/NN-<id>/` with, per language, an optional
lesson page `<lang>.md` and an optional worked example
`<lang>-example.<ext>`. The page's fields (`title`, `learning_goals`, `hints`,
the intro, `<!-- @conclusion -->` and the conclusion) each override the
level's own when present, so a language whose mechanics differ (Lean tactics,
Bend `match`) gets its own text and hints while the level file stays the
source for the rest. The example is a *similar problem worked out*: a full
source file with the same four regions, shown collapsed in the lesson with the
page's `example_explanation` (which should say how to start the exercise).
`refl-check-levels` type-checks every example with the vocabulary earned at
that level, and refuses a lesson that names a command its language does not
offer, or an example that restates the exercise.

The client has a dark and a light theme (button in the header; the choice is
remembered in the browser when storage allows).

After adding Agda levels, regenerate the world support modules so later
levels can `open import Refl.World.<World>`:

```sh
cabal run refl-check-levels -- games/refl --emit-world-modules languages/agda
```

## Status

Worlds 0–4 (Tutorial, Addition, Multiplication, Logic, Equality: 45 levels)
are fully playable in Agda; the Tutorial is also playable in Lean 4 and in
Bend 2. Worlds 5–18 are planned with learning goals per level (see the map).
