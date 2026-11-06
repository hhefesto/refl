# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law succ_mul:
  for +x: Nat
  for +y: Nat
  {Refl.mul(1n+x, y) == Refl.add(Refl.mul(x, y), y) : Nat}
# @template
def succ_mul(x, y):
  ?goal
# @solution
def succ_mul(x, y):
  match y:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(Refl.mul(1n+x, p), x), Refl.add(Refl.add(Refl.mul(x, p), x), p),
        Equal.trans(Nat, Refl.add(Refl.mul(1n+x, p), x), Refl.add(Refl.add(Refl.mul(x, p), p), x), Refl.add(Refl.add(Refl.mul(x, p), x), p),
          Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(1n+x, p), Refl.add(Refl.mul(x, p), p), succ_mul(x, p)),
          Addition.add_right_comm(Refl.mul(x, p), p, x)))
