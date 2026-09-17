# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law flip_chain:
  for -x: Nat
  for -y: Nat
  for -z: Nat
  for p: {y == x : Nat}
  for q: {y == z : Nat}
  {x == z : Nat}
# @template
def flip_chain(x, y, z, p, q):
  ?goal
# @solution
def flip_chain(x, y, z, p, q):
  Equal.trans(Nat, x, y, z, Equal.sym(Nat, y, x, p), q)
