# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law trans_sym:
  for -A: Type
  for -x: A
  for -y: A
  for e: {x == y : A}
  {Equal.trans(A, y, x, y, Equal.sym(A, x, y, e), e) == {==} : {y == y : A}}
# @template
def trans_sym(A, x, y, e):
  ?goal
# @solution
def trans_sym(A, x, y, e):
  %E@e : {Equal.trans(A, _, x, _, Equal.sym(A, x, _, E), E) == {==} : {_ == _ : A}}
  {==}
