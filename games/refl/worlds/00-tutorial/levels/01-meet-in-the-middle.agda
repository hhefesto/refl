-- @prelude
{-# OPTIONS --safe --without-K #-}
module Tutorial.MeetInTheMiddle where

open import Refl.Nat
open import Refl.Eq
open ≡-Reasoning
-- @statement
two-plus-two-by-hand : 2 + 2 ≡ 4
-- @template
two-plus-two-by-hand =
  begin
    2 + 2           ≡⟨⟩
    suc 1 + suc 1   ≡⟨⟩
    ?               ≡⟨⟩   -- walk the left endpoint down to here
    ?               ≡⟨⟩   -- walk the right endpoint up to here
    suc 3           ≡⟨⟩
    4               ∎
-- @solution
two-plus-two-by-hand =
  begin
    2 + 2           ≡⟨⟩
    suc 1 + suc 1   ≡⟨⟩
    suc (suc 1 + 1) ≡⟨⟩
    suc (suc 2)     ≡⟨⟩
    suc 3           ≡⟨⟩
    4               ∎
