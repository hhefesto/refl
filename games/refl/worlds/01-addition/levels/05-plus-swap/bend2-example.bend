# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_inner:
  for +x: Nat
  for +y: Nat
  for -z: Nat
  {Refl.add(Refl.add(x, y), z) == Refl.add(Refl.add(y, x), z) : Nat}
# @template
# example shown below
# @solution
def example_inner(x, y, z):
  Equal.cong(Nat, Nat, n => Refl.add(n, z), Refl.add(x, y), Refl.add(y, x), Addition.add_comm(x, y))
