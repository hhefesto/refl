# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
def zeroed(xs: +List<Nat>) -> +List<Nat>:
  match xs:
    case Nil{}:
      []
    case Con{h, t}:
      0n <> zeroed(t)

law example_zeroed:
  for +xs: +List<Nat>
  {Addition.sum(zeroed(xs)) == 0n : Nat}
# @template
# example shown below
# @solution
def example_zeroed(xs):
  match xs:
    case Nil{}:
      {==}
    case Con{h, t}:
      example_zeroed(t)
