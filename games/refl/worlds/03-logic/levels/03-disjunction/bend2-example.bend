# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_same:
  for -A: Type
  for s: A | A
  A
# @template
# example shown below
# @solution
def example_same(A, s):
  match s:
    case Inl{a}:
      a
    case Inr{a}:
      a
