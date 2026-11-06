# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_flip:
  for -A: Data
  for -B: Type
  for -f: A -> B
  for -g: A -> B
  for p: @x:A -> {f(x) == g(x) : B}
  for +x: A
  {g(x) == f(x) : B}
# @template
# example shown below
# @solution
def example_flip(A, B, f, g, p, x):
  Equal.sym(B, f(x), g(x), p(x))
