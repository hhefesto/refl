# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def copy(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n+k:
      1n+copy(k)

law example_copy:
  for n: Nat
  {copy(n) == n : Nat}
# @template
# example shown below
# @solution
def example_copy(n):
  match n:
    case 0n:
      {==}
    case 1n+k:
      %example_copy(k) : {1n+copy(k) == 1n+_ : Nat}
      {==}
