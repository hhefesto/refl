# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def pick_g(b: Bool, +n: Nat) -> Nat:
  match b:
    case True{}:
      1n
    case False{}:
      n

def g(+n: Nat) -> Nat:
  pick_g(Refl.isZero(n), n)

type Seen<-n: Nat, -b: Bool> is Type:
  Saw{evidence: {Refl.isZero(n) == b : Bool}}

law pick_g_ok:
  for +n: Nat
  for h: {n != 0n : Nat}
  for b: Bool
  for s: Seen<n, b>
  {pick_g(b, n) == n : Nat}

law g_nonzero:
  for +n: Nat
  for h: {n != 0n : Nat}
  {g(n) == n : Nat}
# @template
def pick_g_ok(n, h, b, s):
  ?first

def g_nonzero(n, h):
  ?second
# @solution
def pick_g_ok(n, h, b, s):
  match b s:
    case True{} Saw{e}:
      Empty.absurd({pick_g(True{}, n) == n : Nat}, h(Refl.isZero_true(n, e)))
    case False{} Saw{e}:
      {==}

def g_nonzero(n, h):
  pick_g_ok(n, h, Refl.isZero(n), Saw{{==}})
