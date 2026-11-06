# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law J:
  for -A: Type
  for -x: A
  for -P: @y:A -> @e:{x == y : A} -> Type
  for d: P(x, {==})
  for -y: A
  for p: {x == y : A}
  P(y, p)
# @template
def J(A, x, P, d, y, p):
  ?goal
# @solution
def J(A, x, P, d, y, p):
  %E@p : P(_, E)
  d
