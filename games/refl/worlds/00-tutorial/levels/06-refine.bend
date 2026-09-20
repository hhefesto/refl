# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law three_steps:
  for -x: Nat
  {Refl.add(Refl.add(x, 2n), 1n) == Refl.add(x, 3n) : Nat}
# @template
def three_steps(x):
  ?goal
# @solution
def three_steps(x):
  {==}
