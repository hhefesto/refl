# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
# @statement
def pick(-A: Type, d: Refl.Dec<A>) -> Nat:
  match d:
    case Refl.Yes{p}:
      1n
    case Refl.No{q}:
      0n

def delta(i: Nat, j: Nat) -> Nat:
  pick({i == j : Nat}, Logic.dec_eq(i, j))

law pick_yes:
  for -A: Type
  for a: A
  for d: Refl.Dec<A>
  {pick(A, d) == 1n : Nat}

law delta_diag:
  for +i: Nat
  {delta(i, i) == 1n : Nat}
# @template
def pick_yes(A, a, d):
  ?first

def delta_diag(i):
  ?second
# @solution
def pick_yes(A, a, d):
  match d:
    case Refl.Yes{p}:
      {==}
    case Refl.No{q}:
      Empty.absurd({pick(A, Refl.No{q}) == 1n : Nat}, q(a))

def delta_diag(i):
  pick_yes({i == i : Nat}, {==}, Logic.dec_eq(i, i))
