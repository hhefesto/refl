# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law zero_add:
  for x: Nat
  {Refl.add(0n, x) == x : Nat}
# @template
def zero_add(x):
  ?goal
# @solution
def zero_add(x):
  match x:
    case 0n:
      {==}
    case 1n+p:
      %zero_add(p) : {1n+Refl.add(0n, p) == 1n+_ : Nat}
      {==}
