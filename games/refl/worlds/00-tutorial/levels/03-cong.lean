-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem suc_cong {x y : MyNat} (h : x = y) : succ x = succ y := by
-- @template
  sorry
-- @solution
  rw [h]
