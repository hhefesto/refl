# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law and_swap:
  for -A: Type
  for -B: Type
  for p: A & B
  B & A
# @template
def and_swap(A, B, p):
  ?goal
# @solution
def and_swap(A, B, p):
  (a, b) = p
  (b, a)
