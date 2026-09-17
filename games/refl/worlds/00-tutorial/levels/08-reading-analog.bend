# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def analog1(d: Nat, h: Nat -> Nat, xs: Nat -> Nat) -> Nat -> Nat:
  t => h(xs(Refl.add(t, d)))

law analog1_:
  for d: Nat
  for h: Nat -> Nat
  for xs: Nat -> Nat
  for t: Nat
  Nat

law analog_same:
  for -d: Nat
  for -h: Nat -> Nat
  for -xs: Nat -> Nat
  for -t: Nat
  {analog1(d, h, xs)(t) == analog1_(d, h, xs, t) : Nat}
# @template
def analog1_(d, h, xs, t):
  ?goal1

def analog_same(d, h, xs, t):
  ?goal2
# @solution
def analog1_(d, h, xs, t):
  h(xs(Refl.add(t, d)))

def analog_same(d, h, xs, t):
  {==}
