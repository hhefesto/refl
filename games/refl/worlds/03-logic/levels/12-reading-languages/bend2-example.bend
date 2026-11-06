# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law example_side:
  for -P: Nat -> Type
  for -Q: Nat -> Type
  for -n: Nat
  for pq: P(n) & Q(n)
  Q(n) | P(n)
# @template
# example shown below
# @solution
def example_side(P, Q, n, pq):
  (p, q) = pq
  Inl{q}
