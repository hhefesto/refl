# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_succ:
  for +x: Nat
  for y: Nat
  {Refl.add(1n+x, y) == Refl.add(x, 1n+y) : Nat}
# @template
# example shown below
# @solution
def example_succ(x, y):
  match y:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Refl.add(1n+x, p), Refl.add(x, 1n+p), example_succ(x, p))
