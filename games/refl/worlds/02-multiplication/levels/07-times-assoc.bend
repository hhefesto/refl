# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law mul_assoc:
  for +x: Nat
  for +y: Nat
  for +z: Nat
  {Refl.mul(Refl.mul(x, y), z) == Refl.mul(x, Refl.mul(y, z)) : Nat}
# @template
def mul_assoc(x, y, z):
  ?goal
# @solution
def mul_assoc(x, y, z):
  match z:
    case 0n:
      {==}
    case 1n+p:
      Equal.trans(Nat, Refl.add(Refl.mul(Refl.mul(x, y), p), Refl.mul(x, y)), Refl.add(Refl.mul(x, Refl.mul(y, p)), Refl.mul(x, y)), Refl.mul(x, Refl.add(Refl.mul(y, p), y)),
        Equal.cong(Nat, Nat, n => Refl.add(n, Refl.mul(x, y)), Refl.mul(Refl.mul(x, y), p), Refl.mul(x, Refl.mul(y, p)), mul_assoc(x, y, p)),
        Equal.sym(Nat, Refl.mul(x, Refl.add(Refl.mul(y, p), y)), Refl.add(Refl.mul(x, Refl.mul(y, p)), Refl.mul(x, y)), Multiplication.mul_add(x, Refl.mul(y, p), y)))
