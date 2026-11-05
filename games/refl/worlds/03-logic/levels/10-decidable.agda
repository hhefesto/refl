-- @prelude
{-# OPTIONS --safe --without-K #-}
module Logic.Decidable where

open import Refl.Nat
open import Refl.Eq
open import Refl.Logic
-- @statement
map-suc : ∀ {m n : ℕ} → Dec (m ≡ n) → Dec (suc m ≡ suc n)
map-suc (yes p) = yes (cong suc p)
map-suc (no ¬p) = no (λ { refl → ¬p refl })

infix 4 _≟_
_≟_ : (m n : ℕ) → Dec (m ≡ n)
-- @template
m ≟ n = ?
-- @solution
zero ≟ zero = yes refl
zero ≟ suc n = no (λ ())
suc m ≟ zero = no (λ ())
suc m ≟ suc n = map-suc (m ≟ n)
