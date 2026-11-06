# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
law add_right_cancel:
  for -x: Nat
  for -y: Nat
  for z: Nat
  for h: {Refl.add(x, z) == Refl.add(y, z) : Nat}
  {x == y : Nat}
# @template
def add_right_cancel(x, y, z, h):
  ?goal
# @solution
def add_right_cancel(x, y, z, h):
  match z:
    case 0n:
      h
    case 1n+p:
      add_right_cancel(x, y, p, Addition.succ_inj(Refl.add(x, p), Refl.add(y, p), h))
