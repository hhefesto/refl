# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_nested:
  for -n: Nat
  {Refl.add(Refl.add(n, 1n), 1n) == Refl.add(n, 2n) : Nat}
# @template
# example shown below
# @solution
def example_nested(n):
  {==}
