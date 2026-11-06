# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
def zeros(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      Refl.add(zeros(p), 0n)

law example_zeros:
  for n: Nat
  {zeros(n) == 0n : Nat}
# @template
# example shown below
# @solution
def example_zeros(n):
  match n:
    case 0n:
      {==}
    case 1n+p:
      example_zeros(p)
