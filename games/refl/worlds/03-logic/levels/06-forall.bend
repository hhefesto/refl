# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law forall_pair:
  for -P: Nat -> Type
  for -Q: Nat -> Type
  for p: @n:Nat -> P(n)
  for q: @n:Nat -> Q(n)
  for +n: Nat
  P(n) & Q(n)
# @template
def forall_pair(P, Q, p, q, n):
  ?goal
# @solution
def forall_pair(P, Q, p, q, n):
  (p(n), q(n))
