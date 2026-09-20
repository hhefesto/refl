# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_sub:
  for -n: Nat
  for h: {n == 4n : Nat}
  {Refl.add(n, 1n) == 5n : Nat}
# @template
# example shown below
# @solution
def example_sub(n, h):
  %h : {Refl.add(n, 1n) == 1n+_ : Nat}
  {==}
