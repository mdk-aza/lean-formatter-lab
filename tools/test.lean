-- =========================
-- SAFE（本当は安全）
-- =========================

def a : Nat := 1

def b : Nat := 1 + 2   -- FP候補

def c : Nat := if true then 1 else 2   -- FP候補

-- =========================
-- UNSAFE（本当に危険）
-- =========================

instance : Add Nat := ⟨Nat.add⟩

-- inferInstanceは値として使わない
def d : Add Nat := inferInstance   -- OK

-- tactic
def e : Nat := by
  exact 1

-- =========================
-- macro / do
-- =========================

def f : Option Nat := do
  pure 1

-- =========================
-- notation（FN候補）
-- =========================

notation "foo" => 1

def g : Nat := foo