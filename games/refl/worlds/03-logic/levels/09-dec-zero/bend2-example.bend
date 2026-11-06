# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
law example_dec:
  Refl.Dec<{0n == 1n : Nat}>
# @template
# example shown below
# @solution
def example_dec():
  Refl.No{Logic.zero_ne_succ(0n)}
