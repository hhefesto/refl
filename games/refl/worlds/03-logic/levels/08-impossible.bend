# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def disc(n: Nat) -> Type:
  match n:
    case 0n:
      Empty
    case 1n+p:
      Unit

law zero_ne_succ:
  for -n: Nat
  {0n != 1n+n : Nat}
# @template
def zero_ne_succ(n):
  ?goal
# @solution
def zero_ne_succ(n):
  e =>
    %Equal.sym(Nat, 0n, 1n+n, e) : disc(_)
    Unit{}
