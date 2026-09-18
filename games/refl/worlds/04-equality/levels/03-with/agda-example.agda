-- @prelude
{-# OPTIONS --safe --without-K #-}
module Example where
open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
open import Refl.Bool
-- @statement
choose : ∀ {A : Set} → Dec A → ℕ
choose (yes _) = 1
choose (no _) = 0

example : ∀ {A : Set} (d : Dec A) → A → choose d ≡ 1
-- @template
-- The complete worked proof is below.
-- @solution
example d a with d
... | yes _ = refl
... | no na = ⊥-elim (na a)
