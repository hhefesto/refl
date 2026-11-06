# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_one:
  for +x: Nat
  {Refl.add(x, 1n) == Refl.add(1n, x) : Nat}
# @template
# example shown below
# @solution
def example_one(x):
  Equal.sym(Nat, Refl.add(1n, x), 1n+x,
    Equal.trans(Nat, Refl.add(1n, x), 1n+Refl.add(0n, x), 1n+x,
      Addition.succ_add(0n, x),
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(0n, x), x, Tutorial.zero_add(x))))
