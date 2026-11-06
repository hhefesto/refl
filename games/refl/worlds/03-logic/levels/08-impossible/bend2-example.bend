# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def disc(n: Nat) -> Type:
  match n:
    case 0n:
      Unit
    case 1n+p:
      Empty

law example_ne:
  for -n: Nat
  {1n+n != 0n : Nat}
# @template
# example shown below
# @solution
def example_ne(n):
  e =>
    %Equal.sym(Nat, 1n+n, 0n, e) : disc(_)
    Unit{}
