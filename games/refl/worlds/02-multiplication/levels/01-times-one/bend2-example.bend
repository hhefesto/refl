# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_two:
  for +x: Nat
  {Refl.mul(x, 2n) == Refl.add(x, x) : Nat}
# @template
# example shown below
# @solution
def example_two(x):
  Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.add(0n, x), x, Tutorial.zero_add(x))
