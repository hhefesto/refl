-- @prelude
import Refl.MyNat
open MyNat
-- @statement
def map_succ {m n : MyNat} : Decidable (m = n) → Decidable (succ m = succ n)
  | isTrue p => isTrue (congrArg succ p)
  | isFalse np => isFalse (fun | rfl => np rfl)

def dec_eq (m n : MyNat) : Decidable (m = n) :=
-- @template
  sorry
-- @solution
  match m, n with
  | zero, zero => isTrue rfl
  | zero, succ _ => isFalse (fun h => by cases h)
  | succ _, zero => isFalse (fun h => by cases h)
  | succ m, succ n => map_succ (dec_eq m n)
