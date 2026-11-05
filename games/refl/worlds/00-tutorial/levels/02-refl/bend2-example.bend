# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_sum:
  {Refl.add(20n, 22n) == 42n : Nat}
# @template
# example shown below
# @solution
def example_sum():
  {==}
