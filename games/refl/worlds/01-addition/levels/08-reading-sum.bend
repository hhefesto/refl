# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def sum(xs: +List<Nat>) -> Nat:
  match xs:
    case Nil{}:
      0n
    case Con{h, t}:
      Refl.add(sum(t), h)

def zeros(n: Nat) -> +List<Nat>:
  match n:
    case 0n:
      []
    case 1n+p:
      0n <> zeros(p)

law sum_zeros:
  for n: Nat
  {sum(zeros(n)) == 0n : Nat}
# @template
def sum_zeros(n):
  ?goal
# @solution
def sum_zeros(n):
  match n:
    case 0n:
      {==}
    case 1n+p:
      sum_zeros(p)
