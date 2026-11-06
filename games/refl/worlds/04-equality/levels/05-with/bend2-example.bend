# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
def choose(-A: Type, d: Refl.Dec<A>) -> Nat:
  match d:
    case Refl.Yes{p}:
      1n
    case Refl.No{q}:
      0n

law example_choose:
  for -A: Type
  for a: A
  for d: Refl.Dec<A>
  {choose(A, d) == 1n : Nat}
# @template
# example shown below
# @solution
def example_choose(A, a, d):
  match d:
    case Refl.Yes{p}:
      {==}
    case Refl.No{q}:
      Empty.absurd({choose(A, Refl.No{q}) == 1n : Nat}, q(a))
