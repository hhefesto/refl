-- @prelude
{-# OPTIONS --safe --without-K #-}
module Addition.PlusComm where

open import Refl.Nat
open import Refl.Eq
open import Refl.World.Tutorial using (zero-+)
open import Refl.World.Addition using (suc-+)
-- @statement
+-comm : ∀ (x y : ℕ) → x + y ≡ y + x
-- @template
+-comm x y = ?
-- @solution
+-comm x zero = sym (zero-+ x)
+-comm x (suc y) = trans (cong suc (+-comm x y)) (sym (suc-+ y x))
