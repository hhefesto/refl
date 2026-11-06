-- @prelude
import Refl.MyNat
open MyNat
-- @statement
theorem sym' {A : Type} {x y : A} : x = y → y = x := by
-- @template
  sorry
-- @solution
  exact fun | rfl => rfl
