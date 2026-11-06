# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_or:
  for s: Empty | Unit
  Unit
# @template
# example shown below
# @solution
def example_or(s):
  match s:
    case Inl{e}:
      match e:
    case Inr{u}:
      u
