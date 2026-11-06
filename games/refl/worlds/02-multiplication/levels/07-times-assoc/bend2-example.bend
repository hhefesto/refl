# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law example_sum:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {Refl.add(Refl.mul(a, b), Refl.mul(a, c)) == Refl.mul(a, Refl.add(b, c)) : Nat}
# @template
# example shown below
# @solution
def example_sum(a, b, c):
  Equal.sym(Nat, Refl.mul(a, Refl.add(b, c)), Refl.add(Refl.mul(a, b), Refl.mul(a, c)), Multiplication.mul_add(a, b, c))
