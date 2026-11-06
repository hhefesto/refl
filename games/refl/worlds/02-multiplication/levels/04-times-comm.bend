# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
law mul_comm:
  for +x: Nat
  for +y: Nat
  {Refl.mul(x, y) == Refl.mul(y, x) : Nat}
# @template
def mul_comm(x, y):
  ?goal
# @solution
def mul_comm(x, y):
  match y:
    case 0n:
      Equal.sym(Nat, Refl.mul(0n, x), 0n, Multiplication.zero_mul(x))
    case 1n+p:
      Equal.trans(Nat, Refl.add(Refl.mul(x, p), x), Refl.add(Refl.mul(p, x), x), Refl.mul(1n+p, x),
        Equal.cong(Nat, Nat, n => Refl.add(n, x), Refl.mul(x, p), Refl.mul(p, x), mul_comm(x, p)),
        Equal.sym(Nat, Refl.mul(1n+p, x), Refl.add(Refl.mul(p, x), x), Multiplication.succ_mul(p, x)))
