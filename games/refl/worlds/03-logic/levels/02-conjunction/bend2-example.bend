# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_nest:
  for -A: Type
  for -B: Type
  for -C: Type
  for p: (A & B) & C
  A & (B & C)
# @template
# example shown below
# @solution
def example_nest(A, B, C, p):
  (ab, c) = p
  (a, b) = ab
  (a, (b, c))
