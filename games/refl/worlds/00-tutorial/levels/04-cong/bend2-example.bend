# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_map:
  for -a: Nat
  for -b: Nat
  for h: {a == b : Nat}
  {Refl.add(a, 2n) == Refl.add(b, 2n) : Nat}
# @template
# example shown below
# @solution
def example_map(a, b, h):
  Equal.cong(Nat, Nat, n => Refl.add(n, 2n), a, b, h)
