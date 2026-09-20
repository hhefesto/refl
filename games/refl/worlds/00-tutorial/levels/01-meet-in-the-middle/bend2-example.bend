# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_sum:
  {Refl.add(3n, 1n) == 4n : Nat}
# @template
# example shown below
# @solution
def example_sum():
  middle = {Succ{3n} : Nat}
  left = Refl.step(Refl.add(3n, 1n), middle,
    Refl.step(Succ{Refl.add(3n, 0n)}, middle,
      Refl.arrive(middle)))
  right = Refl.step(4n, middle,
    Refl.arrive(middle))
  Refl.meet(Refl.add(3n, 1n), 4n, middle, left, right)
