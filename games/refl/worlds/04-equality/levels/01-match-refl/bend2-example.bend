# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_add:
  for -a: Nat
  for -b: Nat
  for p: {a == b : Nat}
  {Refl.add(a, 2n) == Refl.add(b, 2n) : Nat}
# @template
# example shown below
# @solution
def example_add(a, b, p):
  %p : {Refl.add(a, 2n) == Refl.add(_, 2n) : Nat}
  {==}
