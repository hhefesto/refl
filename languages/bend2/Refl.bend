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

# A path ends with reflexivity at its meeting point.
law arrive:
  for -point: Nat
  {point == point : Nat}
def arrive(point):
  {==}

# The next path must have this same start (up to computation).
law step:
  for -start: Nat
  for -end: Nat
  for rest: {start == end : Nat}
  {start == end : Nat}
def step(start, end, rest):
  rest

# Join paths that start at opposite endpoints and end at one middle.
law meet:
  for -left: Nat
  for -right: Nat
  for -middle: Nat
  for left_path: {left == middle : Nat}
  for right_path: {right == middle : Nat}
  {left == right : Nat}
def meet(left, right, middle, left_path, right_path):
  Equal.trans(Nat, left, middle, right, left_path, Equal.sym(Nat, right, middle, right_path))
