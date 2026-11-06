# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
law example_unit:
  for -A: Type
  (A -> (A & Unit)) & ((A & Unit) -> A)
# @template
# example shown below
# @solution
def example_unit(A):
  (a => (a, Unit{}), p => Pair.fst(A, Unit, p))
