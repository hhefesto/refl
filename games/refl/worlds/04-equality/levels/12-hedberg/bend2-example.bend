# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
law example_chain:
  for -x: Nat
  for -y: Nat
  for -z: Nat
  for +e: {x == y : Nat}
  for -p: {y == z : Nat}
  for -q: {y == z : Nat}
  for h: {p == q : {y == z : Nat}}
  {Equal.trans(Nat, x, y, z, e, p) == Equal.trans(Nat, x, y, z, e, q) : {x == z : Nat}}
# @template
# example shown below
# @solution
def example_chain(x, y, z, e, p, q, h):
  Equal.cong({y == z : Nat}, {x == z : Nat}, r => Equal.trans(Nat, x, y, z, e, r), p, q, h)
