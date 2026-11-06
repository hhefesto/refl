# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_four:
  exs n: Nat
  {Refl.add(n, 2n) == 6n : Nat}
# @template
# example shown below
# @solution
def example_four():
  (4n, {==})
