# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law sym_:
  for -A: Type
  for -x: A
  for -y: A
  {x == y : A} -> {y == x : A}
# @template
def sym_(A, x, y):
  ?goal
# @solution
def sym_(A, x, y):
  e =>
    %e : {_ == x : A}
    {==}
