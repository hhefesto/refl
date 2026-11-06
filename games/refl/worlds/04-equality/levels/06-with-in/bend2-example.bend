# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_test:
  for +n: Nat
  for h: {n != 0n : Nat}
  for b: Bool
  for e: {Refl.isZero(n) == b : Bool}
  {b == False{} : Bool}
# @template
# example shown below
# @solution
def example_test(n, h, b, e):
  match b:
    case True{}:
      Empty.absurd({True{} == False{} : Bool}, h(Refl.isZero_true(n, e)))
    case False{}:
      {==}
