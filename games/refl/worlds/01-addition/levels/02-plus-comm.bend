# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law add_comm:
  for +x: Nat
  for +y: Nat
  {Refl.add(x, y) == Refl.add(y, x) : Nat}
# @template
def add_comm(x, y):
  ?goal
# @solution
def add_comm(x, y):
  match y:
    case 0n:
      Equal.sym(Nat, Refl.add(0n, x), x, Tutorial.zero_add(x))
    case 1n+p:
      Equal.trans(Nat, 1n+Refl.add(x, p), 1n+Refl.add(p, x), Refl.add(1n+p, x),
        Equal.cong(Nat, Nat, n => 1n+n, Refl.add(x, p), Refl.add(p, x), add_comm(x, p)),
        Equal.sym(Nat, Refl.add(1n+p, x), 1n+Refl.add(p, x), Addition.succ_add(p, x)))
