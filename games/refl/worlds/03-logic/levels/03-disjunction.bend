# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law or_swap:
  for -A: Type
  for -B: Type
  for s: A | B
  B | A
# @template
def or_swap(A, B, s):
  ?goal
# @solution
def or_swap(A, B, s):
  match s:
    case Inl{a}:
      Inr{a}
    case Inr{b}:
      Inl{b}
