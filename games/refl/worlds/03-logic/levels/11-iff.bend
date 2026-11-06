# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
law and_swap_iff:
  for -A: Type
  for -B: Type
  ((A & B) -> (B & A)) & ((B & A) -> (A & B))
# @template
def and_swap_iff(A, B):
  ?goal
# @solution
def and_swap_iff(A, B):
  (p => Logic.and_swap(A, B, p), p => Logic.and_swap(B, A, p))
