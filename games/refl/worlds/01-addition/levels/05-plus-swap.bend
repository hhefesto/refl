# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law add_left_comm:
  for +x: Nat
  for +y: Nat
  for +z: Nat
  {Refl.add(x, Refl.add(y, z)) == Refl.add(y, Refl.add(x, z)) : Nat}
# @template
def add_left_comm(x, y, z):
  ?goal
# @solution
def add_left_comm(x, y, z):
  Equal.trans(Nat, Refl.add(x, Refl.add(y, z)), Refl.add(Refl.add(x, y), z), Refl.add(y, Refl.add(x, z)),
    Equal.sym(Nat, Refl.add(Refl.add(x, y), z), Refl.add(x, Refl.add(y, z)), Addition.add_assoc(x, y, z)),
    Equal.trans(Nat, Refl.add(Refl.add(x, y), z), Refl.add(Refl.add(y, x), z), Refl.add(y, Refl.add(x, z)),
      Equal.cong(Nat, Nat, n => Refl.add(n, z), Refl.add(x, y), Refl.add(y, x), Addition.add_comm(x, y)),
      Addition.add_assoc(y, x, z)))
