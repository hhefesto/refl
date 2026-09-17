# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law two_plus_two:
  {Refl.add(2n, 2n) == 4n : Nat}
# @template
def two_plus_two():
  ?goal
# @solution
def two_plus_two():
  {==}
