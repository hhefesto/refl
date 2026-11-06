# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law mul_add:
  for +x: Nat
  for +y: Nat
  for +z: Nat
  {Refl.mul(x, Refl.add(y, z)) == Refl.add(Refl.mul(x, y), Refl.mul(x, z)) : Nat}
# @template
def mul_add(x, y, z):
  ?goal
# @solution
def mul_add(x, y, z):
  match z:
    case 0n:
      {==}
    case 1n+p:
      Equal.trans(Nat, Refl.add(Refl.mul(x, Refl.add(y, p)), x), Refl.add(Refl.add(Refl.mul(x, y), Refl.mul(x, p)), x), Refl.add(Refl.mul(x, y), Refl.add(Refl.mul(x, p), x)),
        Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(x, Refl.add(y, p)), Refl.add(Refl.mul(x, y), Refl.mul(x, p)), mul_add(x, y, p)),
        Addition.add_assoc(Refl.mul(x, y), Refl.mul(x, p), x))
