# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
law example_one:
  for n: Nat
  Refl.Dec<{n == 1n : Nat}>
# @template
# example shown below
# @solution
def example_one(n):
  match n:
    case 0n:
      Refl.No{Logic.zero_ne_succ(0n)}
    case 1n+0n:
      Refl.Yes{{==}}
    case 2n+p:
      Refl.No{e => Logic.zero_ne_succ(p, Equal.cong(Nat, Nat, Logic.pred, 1n, 2n+p, Equal.sym(Nat, 2n+p, 1n, e)))}
