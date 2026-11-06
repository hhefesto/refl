# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_motive:
  for -A: Type
  for -x: A
  for -y: A
  for p: {x == y : A}
  for -P: A -> Type
  for px: P(x)
  P(y)
# @template
# example shown below
# @solution
def example_motive(A, x, y, p, P, px):
  %p : P(_)
  px
