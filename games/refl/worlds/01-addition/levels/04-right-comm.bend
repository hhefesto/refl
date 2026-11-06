# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law add_right_comm:
  for +x: Nat
  for +y: Nat
  for +z: Nat
  {Refl.add(Refl.add(x, y), z) == Refl.add(Refl.add(x, z), y) : Nat}
# @template
def add_right_comm(x, y, z):
  Equal.trans(Nat, Refl.add(Refl.add(x, y), z), Refl.add(x, Refl.add(y, z)), Refl.add(Refl.add(x, z), y),
    ?first,
    Equal.trans(Nat, Refl.add(x, Refl.add(y, z)), Refl.add(x, Refl.add(z, y)), Refl.add(Refl.add(x, z), y),
      ?second,
      ?third))
# @solution
def add_right_comm(x, y, z):
  Equal.trans(Nat, Refl.add(Refl.add(x, y), z), Refl.add(x, Refl.add(y, z)), Refl.add(Refl.add(x, z), y),
    Addition.add_assoc(x, y, z),
    Equal.trans(Nat, Refl.add(x, Refl.add(y, z)), Refl.add(x, Refl.add(z, y)), Refl.add(Refl.add(x, z), y),
      Equal.cong(Nat, Nat, n => Refl.add(x, n), Refl.add(y, z), Refl.add(z, y), Addition.add_comm(y, z)),
      Equal.sym(Nat, Refl.add(Refl.add(x, z), y), Refl.add(x, Refl.add(z, y)), Addition.add_assoc(x, z, y))))
