# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law one_mul:
  for +x: Nat
  {Refl.mul(1n, x) == x : Nat}
# @template
def one_mul(x):
  ?goal
# @solution
def one_mul(x):
  Equal.trans(Nat, Refl.mul(1n, x), Refl.mul(x, 1n), x, Multiplication.mul_comm(1n, x), Multiplication.mul_one(x))
