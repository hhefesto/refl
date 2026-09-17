{-# OPTIONS --safe --without-K #-}
-- Type-checking this module checks the game's own library. World modules
-- under Refl.World are generated from the levels by
-- `refl-check-levels --emit-world-modules languages/agda`.
-- Refl.Reading.Core is deliberately absent: it re-exports agda-stdlib, whose
-- BUILTIN EQUALITY/NATURAL bindings clash with Refl.Eq/Refl.Nat when both are
-- loaded in one session. It is checked on its own (see flake.nix), and levels
-- that use it never import Refl.Nat or Refl.Eq.
module Refl.Everything where

import Refl.Nat
import Refl.Eq
import Refl.Logic
import Refl.Bool
import Refl.World.Tutorial
import Refl.World.Addition
import Refl.World.Multiplication
import Refl.World.Logic
import Refl.World.Equality
