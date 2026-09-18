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

example : ∀ {A : Set} (d e : Dec A) → choose d ≡ choose e
-- @template
-- The complete worked proof is below.
-- @solution
example d e with d | e
... | yes _ | yes _ = refl
... | yes a | no na = ⊥-elim (na a)
... | no na | yes a = ⊥-elim (na a)
... | no _ | no _ = refl
