# @prelude
import Base
import ./Refl.bend as Refl
# @statement
type Noted<-n: Nat, -b: Bool> is Type:
  Note{evidence: {Refl.isZero(n) == b : Bool}}

law example_test:
  for +n: Nat
  for h: {n != 0n : Nat}
  for b: Bool
  for s: Noted<n, b>
  {b == False{} : Bool}
# @template
# example shown below
# @solution
def example_test(n, h, b, s):
  match b s:
    case True{} Note{e}:
      Empty.absurd({True{} == False{} : Bool}, h(Refl.isZero_true(n, e)))
    case False{} Note{e}:
      {==}
