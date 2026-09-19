# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_sum:
  {Refl.add(3n, 1n) == 4n : Nat}
# @template
# example shown below
# @solution
def example_sum():
  ({==} : {Succ{Succ{Succ{Succ{Zero{}}}}} == Succ{Succ{Succ{Succ{Zero{}}}}} : Nat})
