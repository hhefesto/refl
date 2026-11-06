# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law zero_mul:
  for x: Nat
  {Refl.mul(0n, x) == 0n : Nat}
# @template
def zero_mul(x):
  ?goal
# @solution
def zero_mul(x):
  match x:
    case 0n:
      {==}
    case 1n+p:
      zero_mul(p)
