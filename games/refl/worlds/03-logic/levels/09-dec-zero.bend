# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
law is_zero:
  for n: Nat
  Refl.Dec<{n == 0n : Nat}>
# @template
def is_zero(n):
  ?goal
# @solution
def is_zero(n):
  match n:
    case 0n:
      Refl.Yes{{==}}
    case 1n+p:
      Refl.No{e => Logic.zero_ne_succ(p, Equal.sym(Nat, 1n+p, 0n, e))}
