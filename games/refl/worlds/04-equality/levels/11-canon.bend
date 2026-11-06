# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
law canon_of:
  for -x: Nat
  for -y: Nat
  for d: Refl.Dec<{x == y : Nat}>
  for p: {x == y : Nat}
  {x == y : Nat}

def canon_of(x, y, d, p):
  match d:
    case Refl.Yes{q}:
      q
    case Refl.No{n}:
      Empty.absurd({x == y : Nat}, n(p))

law canon_const:
  for -x: Nat
  for -y: Nat
  for d: Refl.Dec<{x == y : Nat}>
  for p: {x == y : Nat}
  for q: {x == y : Nat}
  {canon_of(x, y, d, p) == canon_of(x, y, d, q) : {x == y : Nat}}

def canon_const(x, y, d, p, q):
  match d:
    case Refl.Yes{r}:
      {==}
    case Refl.No{n}:
      Empty.absurd({canon_of(x, y, Refl.No{n}, p) == canon_of(x, y, Refl.No{n}, q) : {x == y : Nat}}, n(p))

def canon(+x: Nat, +y: Nat, p: {x == y : Nat}) -> {x == y : Nat}:
  canon_of(x, y, Logic.dec_eq(x, y), p)

law canon_inv:
  for +x: Nat
  for +y: Nat
  for p: {x == y : Nat}
  {Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, canon(x, x, {==})), canon(x, y, p)) == p : {x == y : Nat}}
# @template
def canon_inv(x, y, p):
  ?goal
# @solution
def canon_inv(x, y, p):
  %E@p : {Equal.trans(Nat, x, x, _, Equal.sym(Nat, x, x, canon(x, x, {==})), canon(x, _, E)) == E : {x == _ : Nat}}
  Equality.trans_sym(Nat, x, x, canon(x, x, {==}))
