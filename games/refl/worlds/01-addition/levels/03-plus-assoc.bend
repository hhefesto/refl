# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law add_assoc:
  for +x: Nat
  for +y: Nat
  for z: Nat
  {Refl.add(Refl.add(x, y), z) == Refl.add(x, Refl.add(y, z)) : Nat}
# @template
def add_assoc(x, y, z):
  ?goal
# @solution
def add_assoc(x, y, z):
  match z:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(Refl.add(x, y), p), Refl.add(x, Refl.add(y, p)), add_assoc(x, y, p))
