# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_five:
  for -a: Nat
  for -b: Nat
  for p: {a == 1n : Nat}
  for q: {b == 4n : Nat}
  {Refl.add(a, b) == 5n : Nat}
# @template
# example shown below
# @solution
def example_five(a, b, p, q):
  %Equal.sym(Nat, a, 1n, p) : {Refl.add(_, b) == 5n : Nat}
  %Equal.sym(Nat, b, 4n, q) : {Refl.add(1n, _) == 5n : Nat}
  {==}
