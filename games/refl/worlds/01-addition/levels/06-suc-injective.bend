# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

law succ_inj:
  for -x: Nat
  for -y: Nat
  for h: {1n+x == 1n+y : Nat}
  {x == y : Nat}
# @template
def succ_inj(x, y, h):
  ?goal
# @solution
def succ_inj(x, y, h):
  Equal.cong(Nat, Nat, pred, 1n+x, 1n+y, h)
