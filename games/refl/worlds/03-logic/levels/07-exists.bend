# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law witness:
  exs n: Nat
  {Refl.add(n, 1n) == 3n : Nat}
# @template
def witness():
  ?goal
# @solution
def witness():
  (2n, {==})
