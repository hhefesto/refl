# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law suc_cong:
  for -x: Nat
  for -y: Nat
  for h: {x == y : Nat}
  {1n+x == 1n+y : Nat}
# @template
def suc_cong(x, y, h):
  ?goal
# @solution
def suc_cong(x, y, h):
  Equal.cong(Nat, Nat, n => 1n+n, x, y, h)
