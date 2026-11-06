# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
law example_diag:
  for +i: Nat
  {Equality.delta(i, i) == 1n : Nat}
# @template
# example shown below
# @solution
def example_diag(i):
  Equality.pick_yes({i == i : Nat}, {==}, Logic.dec_eq(i, i))
