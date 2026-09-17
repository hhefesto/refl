{-# OPTIONS --safe --without-K #-}
-- Type-checking this module checks the whole support library. World modules
-- under Refl.World are generated from the levels by
-- `refl-check-levels --emit-world-modules languages/agda`.
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
