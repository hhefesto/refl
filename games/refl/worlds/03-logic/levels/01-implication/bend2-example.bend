# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_chain:
  for -A: Type
  for -B: Type
  for -C: Type
  for f: A -> B
  for g: B -> C
  for a: A
  C
# @template
# example shown below
# @solution
def example_chain(A, B, C, f, g, a):
  g(f(a))
