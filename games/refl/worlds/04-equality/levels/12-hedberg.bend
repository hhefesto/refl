# @prelude
import Base
import ./Refl.bend as Refl
import ./Logic.bend as Logic
import ./Equality.bend as Equality
# @statement
law eq_irrelevant:
  for +x: Nat
  for +y: Nat
  for +p: {x == y : Nat}
  for +q: {x == y : Nat}
  {p == q : {x == y : Nat}}
# @template
def eq_irrelevant(x, y, p, q):
  Equal.trans({x == y : Nat}, p, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, q)), q,
    Equal.trans({x == y : Nat}, p, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, p)), Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, q)),
      ?first,
      ?second),
    ?third)
# @solution
def eq_irrelevant(x, y, p, q):
  Equal.trans({x == y : Nat}, p, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, q)), q,
    Equal.trans({x == y : Nat}, p, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, p)), Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, q)),
      Equal.sym({x == y : Nat}, Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), Equality.canon(x, y, p)), p, Equality.canon_inv(x, y, p)),
      Equal.cong({x == y : Nat}, {x == y : Nat}, r => Equal.trans(Nat, x, x, y, Equal.sym(Nat, x, x, Equality.canon(x, x, {==})), r), Equality.canon(x, y, p), Equality.canon(x, y, q), Equality.canon_const(x, y, Logic.dec_eq(x, y), p, q))),
    Equality.canon_inv(x, y, q))
