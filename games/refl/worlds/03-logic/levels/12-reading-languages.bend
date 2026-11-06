# @prelude
import Base
import ./Refl.bend as Refl
# @statement
def union(-P: Nat -> Type, -Q: Nat -> Type, n: Nat) -> Type:
  P(n) | Q(n)

def inter(-P: Nat -> Type, -Q: Nat -> Type, n: Nat) -> Type:
  P(n) & Q(n)

law inter_sub_union:
  for -P: Nat -> Type
  for -Q: Nat -> Type
  for -n: Nat
  for pq: inter(P, Q, n)
  union(P, Q, n)
# @template
def inter_sub_union(P, Q, n, pq):
  ?goal
# @solution
def inter_sub_union(P, Q, n, pq):
  (p, q) = pq
  Inl{p}
