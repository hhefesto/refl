# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def un(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      p

law example_two:
  for -a: Nat
  for -b: Nat
  for h: {2n+a == 2n+b : Nat}
  {a == b : Nat}
# @template
# example shown below
# @solution
def example_two(a, b, h):
  Equal.cong(Nat, Nat, n => un(un(n)), 2n+a, 2n+b, h)
