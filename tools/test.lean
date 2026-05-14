-- =========================
-- SAFE（本当は安全）
-- =========================

def a : Nat := 1

def b : Nat := 1 + 2   -- FP候補（単純式）

def c : Nat := if true then 1 else 2   -- FP候補（ifは実は安全なケースあり）

def h : Nat :=
  let x := 1
  x + 2   -- FP候補（let）

def i : Nat :=
  match true with
  | true => 1
  | false => 2   -- FP候補（match）

def j (x : Nat) : Nat :=
  x + 1   -- FP候補（引数付き）

def k : Nat :=
  (fun x => x + 1) 2   -- FP候補（λ）

-- =========================
-- UNSAFE（本当に危険）
-- =========================

instance : Add Nat := ⟨Nat.add⟩

def d : Add Nat := inferInstance   -- instance依存

def e : Nat := by
  exact 1   -- tactic（構造壊れる）

-- implicit + instance
def m [Add Nat] : Nat :=
  1 + 2   -- instance解決依存

-- =========================
-- macro / do
-- =========================

def f : Option Nat := do
  pure 1

-- do + bind
def n : Option Nat := do
  let x ← some 1
  pure (x + 1)   -- 順序依存

-- =========================
-- notation（FN候補）
-- =========================

notation "foo" => 1

def g : Nat := foo   -- FN候補（notation）

notation a "⊕" b => a + b

def o : Nat := 1 ⊕ 2   -- FN候補（custom infix）

-- =========================
-- 定義展開（aggressive）
-- =========================

def p := 1 + 2
def q := p   -- inlineすると構造変わる

-- =========================
-- defEqで同じだが構文違う
-- =========================

def r : Nat := 1 + 2

def s : Nat := (fun x => x) (1 + 2)   -- defEq OK

-- =========================
-- 型だけ同じ（危険）
-- =========================

def t : Nat := 1
def u : Nat := 2   -- succeedsは同じだが意味違う

-- =========================
-- implicit引数（危険）
-- =========================

def v {α : Type} (x : α) := x

def w := v 1   -- implicit補完あり

-- =========================
-- dependent（PLっぽい）
-- =========================

def dep (n : Nat) : Fin (n + 1) :=
  ⟨0, Nat.succ_pos _⟩

def dep2 := dep 1   -- dependent typing

-- =========================
-- コメント保持テスト
-- =========================

def x : Nat := 1   -- コメント保持

def y : Nat :=
  1 + 2   -- inlineコメント

-- =========================
-- 正規化（idempotence）
-- =========================

def z : Nat := 1 + 2
-- 2回fmtして変わらないか確認