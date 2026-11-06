# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law contraposition:
  for -A: Type
  for -B: Type
  for f: A -> B
  for nb: B -> Empty
  for a: A
  Empty
# @template
def contraposition(A, B, f, nb, a):
  ?goal
# @solution
def contraposition(A, B, f, nb, a):
  nb(f(a))
