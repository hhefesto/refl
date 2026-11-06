# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law example_plus:
  for +x: Nat
  {Refl.add(Refl.mul(1n, x), 0n) == x : Nat}
# @template
# example shown below
# @solution
def example_plus(x):
  Equal.trans(Nat, Refl.mul(1n, x), Refl.mul(x, 1n), x, Multiplication.mul_comm(1n, x), Multiplication.mul_one(x))
