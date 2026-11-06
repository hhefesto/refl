# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law modus_ponens:
  for -A: Type
  for -B: Type
  for a: A
  for f: A -> B
  B
# @template
def modus_ponens(A, B, a, f):
  ?goal
# @solution
def modus_ponens(A, B, a, f):
  f(a)
