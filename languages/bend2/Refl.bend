import Base

# The Refl Game's own addition, by recursion on the second argument exactly
# as in the Agda levels: add(x, 0n) == x is refl, add(0n, x) == x needs
# induction. Base's Nat.add recurses on the first argument, so it would make
# the Tutorial's induction level trivial.
law add:
  for a: Nat
  for b: Nat
  Nat

def add(a, b):
  match b:
    case 0n:
      a
    case 1n+p:
      1n+add(a, p)
