# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_refl:
  for -A: Type
  for -x: A
  for -y: A
  for p: {x == y : A}
  {Equal.trans(A, x, y, y, p, {==}) == p : {x == y : A}}
# @template
# example shown below
# @solution
def example_refl(A, x, y, p):
  %E@p : {Equal.trans(A, x, _, _, E, {==}) == E : {x == _ : A}}
  {==}
