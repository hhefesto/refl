-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def analog₁ (δ : MyNat) (h : MyNat → MyNat) (xs : MyNat → MyNat) : MyNat → MyNat :=
  fun t => h (xs (t + δ))

def analog₁' (δ : MyNat) (h : MyNat → MyNat) (xs : MyNat → MyNat) (t : MyNat) : MyNat :=
  h (xs (t + δ))

theorem analog_same (δ : MyNat) (h : MyNat → MyNat) (xs : MyNat → MyNat) (t : MyNat) :
    analog₁ δ h xs t = analog₁' δ h xs t := by
-- @template
  sorry
-- @solution
  rfl
