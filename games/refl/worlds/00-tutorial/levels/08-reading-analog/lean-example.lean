-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def shifted (k : MyNat) : MyNat → MyNat := fun n => n + k
def shifted' (k n : MyNat) : MyNat := n + k

theorem example_shift (k n : MyNat) : shifted k n = shifted' k n := by
-- @template
  sorry
-- @solution
  rfl
