# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
# @statement
def wrap(n: Nat, x: Nat) -> Nat:
  match n:
    case 0n:
      x
    case 1n+p:
      1n+wrap(p, x)

law example_wrap:
  for n: Nat
  for -x: Nat
  for -y: Nat
  for h: {wrap(n, x) == wrap(n, y) : Nat}
  {x == y : Nat}
# @template
# example shown below
# @solution
def example_wrap(n, x, y, h):
  match n:
    case 0n:
      h
    case 1n+p:
      example_wrap(p, x, y, Addition.succ_inj(wrap(p, x), wrap(p, y), h))
