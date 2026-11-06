-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def Pred := MyNat → Prop
def union (P Q : Pred) : Pred := fun n => P n ∨ Q n
def inter (P Q : Pred) : Pred := fun n => P n ∧ Q n

theorem inter_sub_union (P Q : Pred) (n : MyNat) (pq : inter P Q n) : union P Q n := by
-- @template
  sorry
-- @solution
  cases pq with
  | intro p _ => exact Or.inl p
