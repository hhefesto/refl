# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law two_three:
  for -x: Nat
  for -y: Nat
  for p: {x == 2n : Nat}
  for q: {y == 3n : Nat}
  {Refl.add(x, y) == 5n : Nat}
# @template
def two_three(x, y, p, q):
  ?goal
# @solution
def two_three(x, y, p, q):
  %Equal.sym(Nat, x, 2n, p) : {Refl.add(_, y) == 5n : Nat}
  %Equal.sym(Nat, y, 3n, q) : {Refl.add(2n, _) == 5n : Nat}
  {==}
