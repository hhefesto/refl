# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_outer:
  for +a: Nat
  for +b: Nat
  for +c: Nat
  {1n+Refl.add(Refl.add(a, b), c) == 1n+Refl.add(a, Refl.add(b, c)) : Nat}
# @template
# example shown below
# @solution
def example_outer(a, b, c):
  Equal.cong(Nat, Nat, n => 1n+n, Refl.add(Refl.add(a, b), c), Refl.add(a, Refl.add(b, c)), Addition.add_assoc(a, b, c))
