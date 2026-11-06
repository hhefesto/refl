# @prelude
import Base
import ./Refl.bend as Refl
# @statement
law cong_app:
  for -A: Type
  for -B: Type
  for -f: A -> B
  for -g: A -> B
  for e: {f == g : A -> B}
  for -x: A
  {f(x) == g(x) : B}

def Pointwise(-A: Type, -B: Type, -f: A -> B, -g: A -> B) -> Type:
  @x:A -> {f(x) == g(x) : B}

law pointwise_trans:
  for -A: Data
  for -B: Type
  for -f: A -> B
  for -g: A -> B
  for -h: A -> B
  for p: Pointwise(A, B, f, g)
  for q: Pointwise(A, B, g, h)
  for +x: A
  {f(x) == h(x) : B}
# @template
def cong_app(A, B, f, g, e, x):
  ?first

def pointwise_trans(A, B, f, g, h, p, q, x):
  ?second
# @solution
def cong_app(A, B, f, g, e, x):
  %e : {f(x) == _(x) : B}
  {==}

def pointwise_trans(A, B, f, g, h, p, q, x):
  Equal.trans(B, f(x), g(x), h(x), p(x), q(x))
