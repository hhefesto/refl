# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_move:
  for -a: Nat
  for -b: Nat
  for p: {a == b : Nat}
  for h: {Refl.add(a, 1n) == 5n : Nat}
  {Refl.add(b, 1n) == 5n : Nat}
# @template
# example shown below
# @solution
def example_move(a, b, p, h):
  Refl.subst(Nat, n => {Refl.add(n, 1n) == 5n : Nat}, a, b, p, h)
