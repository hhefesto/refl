# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_succ:
  for -a: Nat
  for -b: Nat
  {a == b : Nat} -> {1n+a == 1n+b : Nat}
# @template
# example shown below
# @solution
def example_succ(a, b):
  e =>
    %e : {1n+a == 1n+_ : Nat}
    {==}
