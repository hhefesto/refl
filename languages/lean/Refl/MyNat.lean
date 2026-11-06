/-! The game's own natural numbers for the Lean track, with the
    same definitions as the Agda track: addition recurses on the second argument. -/

inductive MyNat where
  | zero : MyNat
  | succ : MyNat → MyNat
  deriving Repr, DecidableEq

namespace MyNat

def add : MyNat → MyNat → MyNat
  | m, zero => m
  | m, succ n => succ (add m n)

instance : Add MyNat := ⟨add⟩

def mul : MyNat → MyNat → MyNat
  | _, zero => zero
  | m, succ n => mul m n + m

instance : Mul MyNat := ⟨mul⟩

def pow : MyNat → MyNat → MyNat
  | _, zero => succ zero
  | m, succ n => pow m n * m

instance : Pow MyNat MyNat := ⟨pow⟩

-- A test that answers with a Bool, for the levels about remembering what a test said.
def isZero : MyNat → Bool
  | zero => true
  | succ _ => false

def ofNat : Nat → MyNat
  | 0 => zero
  | n + 1 => succ (ofNat n)

instance : OfNat MyNat n := ⟨ofNat n⟩

theorem add_zero (m : MyNat) : m + 0 = m := rfl
theorem add_succ (m n : MyNat) : m + succ n = succ (m + n) := rfl
theorem mul_zero (m : MyNat) : m * 0 = 0 := rfl
theorem mul_succ (m n : MyNat) : m * succ n = m * n + m := rfl
theorem pow_succ (m n : MyNat) : m ^ succ n = m ^ n * m := rfl
theorem isZero_true : ∀ {n : MyNat}, isZero n = true → n = zero
  | zero, _ => rfl

end MyNat
