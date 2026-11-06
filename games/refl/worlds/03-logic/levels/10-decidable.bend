# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
def pred(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

law map_succ:
  for -m: Nat
  for -n: Nat
  for d: Refl.Dec<{m == n : Nat}>
  Refl.Dec<{1n+m == 1n+n : Nat}>

def map_succ(m, n, d):
  match d:
    case Refl.Yes{p}:
      Refl.Yes{Equal.cong(Nat, Nat, x => 1n+x, m, n, p)}
    case Refl.No{np}:
      Refl.No{e => np(Equal.cong(Nat, Nat, pred, 1n+m, 1n+n, e))}

law dec_eq:
  for m: Nat
  for n: Nat
  Refl.Dec<{m == n : Nat}>
# @template
def dec_eq(m, n):
  ?goal
# @solution
def dec_eq(m, n):
  match m n:
    case 0n 0n:
      Refl.Yes{{==}}
    case 0n 1n+q:
      Refl.No{Logic.zero_ne_succ(q)}
    case 1n+p 0n:
      Refl.No{e => Logic.zero_ne_succ(p, Equal.sym(Nat, 1n+p, 0n, e))}
    case 1n+p 1n+q:
      map_succ(p, q, dec_eq(p, q))
