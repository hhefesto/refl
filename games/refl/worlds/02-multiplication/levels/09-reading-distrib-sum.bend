# @prelude
import Base
import ./Refl.bend as Refl
import ./Tutorial.bend as Tutorial
import ./Addition.bend as Addition
import ./Multiplication.bend as Multiplication
# @statement
def scale(+c: Nat, xs: +List<Nat>) -> +List<Nat>:
  match xs:
    case Nil{}:
      []
    case Con{h, t}:
      Refl.mul(c, h) <> scale(c, t)

law sum_factor:
  for +c: Nat
  for +xs: +List<Nat>
  {Addition.sum(scale(c, xs)) == Refl.mul(c, Addition.sum(xs)) : Nat}
# @template
def sum_factor(c, xs):
  ?goal
# @solution
def sum_factor(c, xs):
  match xs:
    case Nil{}:
      {==}
    case Con{h, t}:
      Equal.trans(Nat, Refl.add(Addition.sum(scale(c, t)), Refl.mul(c, h)), Refl.add(Refl.mul(c, Addition.sum(t)), Refl.mul(c, h)), Refl.mul(c, Refl.add(Addition.sum(t), h)),
        Equal.cong(Nat, Nat, n => Refl.add(n, Refl.mul(c, h)), Addition.sum(scale(c, t)), Refl.mul(c, Addition.sum(t)), sum_factor(c, t)),
        Equal.sym(Nat, Refl.mul(c, Refl.add(Addition.sum(t), h)), Refl.add(Refl.mul(c, Addition.sum(t)), Refl.mul(c, h)), Multiplication.mul_add(c, Addition.sum(t), h)))
