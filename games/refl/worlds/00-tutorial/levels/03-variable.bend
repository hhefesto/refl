# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law same:
  for -x: Nat
  {x == x : Nat}
# @template
def same(x):
  ?goal
# @solution
def same(x):
  {==}
