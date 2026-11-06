# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
law pick_sym:
  for +i: Nat
  for +j: Nat
  for d: Refl.Dec<{i == j : Nat}>
  for b: Refl.Dec<{j == i : Nat}>
  {Equality.pick({i == j : Nat}, d) == Equality.pick({j == i : Nat}, b) : Nat}

law delta_sym:
  for +i: Nat
  for +j: Nat
  {Equality.delta(i, j) == Equality.delta(j, i) : Nat}
# @template
def pick_sym(i, j, d, b):
  ?first

def delta_sym(i, j):
  ?second
# @solution
def pick_sym(i, j, d, b):
  match d b:
    case Refl.Yes{p} Refl.Yes{q}:
      {==}
    case Refl.Yes{p} Refl.No{nq}:
      Empty.absurd({1n == 0n : Nat}, nq(Equal.sym(Nat, i, j, p)))
    case Refl.No{np} Refl.Yes{q}:
      Empty.absurd({0n == 1n : Nat}, np(Equal.sym(Nat, j, i, q)))
    case Refl.No{np} Refl.No{nq}:
      {==}

def delta_sym(i, j):
  pick_sym(i, j, Logic.dec_eq(i, j), Logic.dec_eq(j, i))
