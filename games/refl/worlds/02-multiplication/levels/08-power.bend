# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law pow_two:
  for +x: Nat
  {Refl.pow(x, 2n) == Refl.mul(x, x) : Nat}
# @template
def pow_two(x):
  ?goal
# @solution
def pow_two(x):
  Equal.cong(Nat, Nat, n => Refl.mul(n, x), Refl.mul(1n, x), x, Multiplication.one_mul(x))
