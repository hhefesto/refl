# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_not_not:
  for -A: Type
  for a: A
  for notA: A -> Empty
  Empty
# @template
# example shown below
# @solution
def example_not_not(A, a, notA):
  notA(a)
