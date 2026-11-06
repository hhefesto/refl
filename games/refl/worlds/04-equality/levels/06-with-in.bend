# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def pick_b(b: Bool, +n: Nat) -> Nat:
  match b:
    case True{}:
      1n
    case False{}:
      n

def f(+n: Nat) -> Nat:
  pick_b(Refl.isZero(n), n)

law pick_b_ok:
  for +n: Nat
  for h: {n != 0n : Nat}
  for b: Bool
  for e: {Refl.isZero(n) == b : Bool}
  {pick_b(b, n) == n : Nat}

law f_nonzero:
  for +n: Nat
  for h: {n != 0n : Nat}
  {f(n) == n : Nat}
# @template
def pick_b_ok(n, h, b, e):
  ?first

def f_nonzero(n, h):
  ?second
# @solution
def pick_b_ok(n, h, b, e):
  match b:
    case True{}:
      Empty.absurd({pick_b(True{}, n) == n : Nat}, h(Refl.isZero_true(n, e)))
    case False{}:
      {==}

def f_nonzero(n, h):
  pick_b_ok(n, h, Refl.isZero(n), {==})
