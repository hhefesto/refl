# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law succ_add:
  for +x: Nat
  for y: Nat
  {Refl.add(1n+x, y) == 1n+Refl.add(x, y) : Nat}
# @template
def succ_add(x, y):
  ?goal
# @solution
def succ_add(x, y):
  match y:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(1n+x, p), 1n+Refl.add(x, p), succ_add(x, p))
