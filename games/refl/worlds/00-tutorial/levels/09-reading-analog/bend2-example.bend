# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def shifted(k: Nat) -> Nat -> Nat:
  n => Refl.add(n, k)

def shifted_explicit(k: Nat, n: Nat) -> Nat:
  Refl.add(n, k)

law example_shift:
  for -k: Nat
  for -n: Nat
  {shifted(k)(n) == shifted_explicit(k, n) : Nat}
# @template
# example shown below
# @solution
def example_shift(k, n):
  {==}
