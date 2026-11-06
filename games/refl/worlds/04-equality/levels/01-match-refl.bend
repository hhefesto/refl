# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law cong_:
  for -A: Type
  for -B: Type
  for -f: A -> B
  for -x: A
  for -y: A
  for p: {x == y : A}
  {f(x) == f(y) : B}
# @template
def cong_(A, B, f, x, y, p):
  ?goal
# @solution
def cong_(A, B, f, x, y, p):
  %p : {f(x) == f(_) : B}
  {==}
