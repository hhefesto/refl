# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law mul_one:
  for +x: Nat
  {Refl.mul(x, 1n) == x : Nat}
# @template
def mul_one(x):
  ?goal
# @solution
def mul_one(x):
  Tutorial.zero_add(x)
