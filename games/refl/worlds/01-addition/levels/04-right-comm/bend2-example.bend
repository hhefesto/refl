# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_chain:
  for -a: Nat
  for -b: Nat
  for -c: Nat
  for p: {a == b : Nat}
  for q: {b == c : Nat}
  {1n+a == 1n+c : Nat}
# @template
# example shown below
# @solution
def example_chain(a, b, c, p, q):
  Equal.trans(Nat, 1n+a, 1n+b, 1n+c,
    Equal.cong(Nat, Nat, n => 1n+n, a, b, p),
    Equal.cong(Nat, Nat, n => 1n+n, b, c, q))
