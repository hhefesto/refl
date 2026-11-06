# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_twice:
  for -P: Nat -> Type
  for p: @n:Nat -> P(n)
  P(2n)
# @template
# example shown below
# @solution
def example_twice(P, p):
  p(2n)
