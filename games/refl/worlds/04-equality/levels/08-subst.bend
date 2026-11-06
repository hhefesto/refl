# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law trans_:
  for -x: Nat
  for -y: Nat
  for -z: Nat
  for p: {x == y : Nat}
  for q: {y == z : Nat}
  {x == z : Nat}
# @template
def trans_(x, y, z, p, q):
  ?goal
# @solution
def trans_(x, y, z, p, q):
  Refl.subst(Nat, w => {x == w : Nat}, y, z, q, p)
