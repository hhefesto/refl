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

# Multiplication and powers, by recursion on the second argument, the same way.
law mul:
  for +a: Nat
  for b: Nat
  Nat

def mul(a, b):
  match b:
    case 0n:
      0n
    case 1n+p:
      add(mul(a, p), a)

law pow:
  for +a: Nat
  for b: Nat
  Nat

def pow(a, b):
  match b:
    case 0n:
      1n
    case 1n+p:
      mul(pow(a, p), a)

# A decision with evidence: a proof, or a refutation.
type Dec<-A: Type> is Type:
  Yes{proof: A}
  No{refute: A -> Empty}

# A test that answers with a Bool, for the levels about remembering what a test said.
def isZero(n: Nat) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+p:
      False{}

law isZero_true:
  for n: Nat
  for e: {isZero(n) == True{} : Bool}
  {n == 0n : Nat}

def bool_clash(b: Bool) -> Type:
  match b:
    case False{}:
      Empty
    case True{}:
      Unit

def isZero_true(n, e):
  match n:
    case 0n:
      {==}
    case 1n+p:
      Empty.absurd({1n+p == 0n : Nat}, (%Equal.sym(Bool, False{}, True{}, e) : bool_clash(_); Unit{}))

# Whatever is true of one thing is true of anything equal to it.
law subst:
  for -A: Type
  for -P: A -> Type
  for -x: A
  for -y: A
  for e: {x == y : A}
  for px: P(x)
  P(y)

def subst(A, P, x, y, e, px):
  %e : P(_)
  px
