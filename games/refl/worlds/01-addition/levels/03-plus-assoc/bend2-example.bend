# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_assoc:
  for +x: Nat
  for +y: Nat
  for z: Nat
  {Refl.add(x, Refl.add(y, z)) == Refl.add(Refl.add(x, y), z) : Nat}
# @template
# example shown below
# @solution
def example_assoc(x, y, z):
  match z:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(x, Refl.add(y, p)), Refl.add(Refl.add(x, y), p), example_assoc(x, y, p))
