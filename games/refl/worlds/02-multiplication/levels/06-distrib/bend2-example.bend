# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law example_two:
  for +x: Nat
  for +y: Nat
  {Refl.mul(x, Refl.add(y, 2n)) == Refl.add(Refl.mul(x, y), Refl.mul(x, 2n)) : Nat}
# @template
# example shown below
# @solution
def example_two(x, y):
  Equal.trans(Nat, Refl.add(Refl.add(Refl.mul(x, y), x), x), Refl.add(Refl.mul(x, y), Refl.add(x, x)), Refl.add(Refl.mul(x, y), Refl.mul(x, 2n)),
    Addition.add_assoc(Refl.mul(x, y), x, x),
    Equal.cong(Nat, Nat, n => Refl.add(Refl.mul(x, y), Refl.add(n, x)), x, Refl.add(0n, x), Equal.sym(Nat, Refl.add(0n, x), x, Tutorial.zero_add(x))))
