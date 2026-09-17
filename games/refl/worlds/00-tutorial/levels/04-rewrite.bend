# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law use_h:
  for -x: Nat
  for h: {x == 3n : Nat}
  {Refl.add(x, 2n) == 5n : Nat}
# @template
def use_h(x, h):
  ?goal
# @solution
def use_h(x, h):
  %h : {Refl.add(x, 2n) == 2n+_ : Nat}
  {==}
