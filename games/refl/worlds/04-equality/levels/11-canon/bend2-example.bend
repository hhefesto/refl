# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
def pick_proof(-x: Nat, -y: Nat, p: {x == y : Nat}) -> {x == y : Nat}:
  p

law example_pick:
  for +x: Nat
  for -y: Nat
  for p: {x == y : Nat}
  {Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, pick_proof(x, x, {==})), pick_proof(x, y, p)) == p : {x == y : Nat}}
# @template
# example shown below
# @solution
def example_pick(x, y, p):
  %E@p : {Equal.trans(Nat, x, x, _, Equal.sym(Nat, x, x, pick_proof(x, x, {==})), pick_proof(x, _, E)) == E : {x == _ : Nat}}
  Equality.trans_sym(Nat, x, x, pick_proof(x, x, {==}))
