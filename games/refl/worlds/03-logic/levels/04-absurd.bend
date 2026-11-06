# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law ex_falso:
  for -A: Type
  for h: Empty
  A

law trivial:
  Unit
# @template
def ex_falso(A, h):
  ?first

def trivial():
  ?second
# @solution
def ex_falso(A, h):
  match h:

def trivial():
  Unit{}
