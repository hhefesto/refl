# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law two_plus_two_by_hand:
  {Refl.add(2n, 2n) == 4n : Nat}
# @template
def two_plus_two_by_hand():
  middle = {Succ{Succ{2n}} : Nat}
  left = Refl.step(Refl.add(2n, 2n), middle,
    Refl.step(Succ{Refl.add(2n, 1n)}, middle,
      Refl.step(?left, middle,
        Refl.arrive(middle))))
  right = Refl.step(4n, middle,
    Refl.step(Succ{3n}, middle,
      Refl.step(?right, middle,
        Refl.arrive(middle))))
  Refl.meet(Refl.add(2n, 2n), 4n, middle, left, right)
# @solution
def two_plus_two_by_hand():
  middle = {Succ{Succ{2n}} : Nat}
  left = Refl.step(Refl.add(2n, 2n), middle,
    Refl.step(Succ{Refl.add(2n, 1n)}, middle,
      Refl.step(Succ{Succ{Refl.add(2n, 0n)}}, middle,
        Refl.arrive(middle))))
  right = Refl.step(4n, middle,
    Refl.step(Succ{3n}, middle,
      Refl.step(Succ{Succ{2n}}, middle,
        Refl.arrive(middle))))
  Refl.meet(Refl.add(2n, 2n), 4n, middle, left, right)
