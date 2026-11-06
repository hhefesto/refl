# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def count(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+p:
      Refl.add(count(p), 1n)

law count_id:
  for n: Nat
  {count(n) == n : Nat}
# @template
# example shown below
# @solution
def count_id(n):
  match n:
    case 0n:
      {==}
    case 1n+p:
      Equal.cong(Nat, Nat, m => 1n+m, count(p), p, count_id(p))
