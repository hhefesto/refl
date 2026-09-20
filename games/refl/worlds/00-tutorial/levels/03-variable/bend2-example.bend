# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_identity:
  for -n: Nat
  {Refl.add(n, 0n) == n : Nat}
# @template
# example shown below
# @solution
def example_identity(n):
  {==}
