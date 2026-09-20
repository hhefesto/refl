# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_chain:
  for -a: Nat
  for -b: Nat
  for -c: Nat
  for p: {a == b : Nat}
  for q: {c == b : Nat}
  {a == c : Nat}
# @template
# example shown below
# @solution
def example_chain(a, b, c, p, q):
  Equal.trans(Nat, a, b, c, p, Equal.sym(Nat, c, b, q))
