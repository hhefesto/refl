# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law example_zero:
  for +x: Nat
  {Refl.mul(0n, x) == Refl.mul(x, 0n) : Nat}
# @template
# example shown below
# @solution
def example_zero(x):
  Multiplication.zero_mul(x)
