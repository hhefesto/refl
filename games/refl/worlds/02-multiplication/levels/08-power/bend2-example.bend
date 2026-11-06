# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law example_pow:
  for +x: Nat
  {Refl.pow(x, 1n) == x : Nat}
# @template
# example shown below
# @solution
def example_pow(x):
  Multiplication.one_mul(x)
