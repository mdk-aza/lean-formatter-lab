import Lean

/-
cannot print: Unknown constant `«|»`
#eval do let stx ← `( term | ` ` x ) let fmt ← Lean.PrettyPrinter.ppTerm stx IO.println fmt.pretty
-/

/-
cannot print: Unknown constant `«|»`
#eval do let stx ← `( term | ` ` Parser.Module.header ) let fmt ← Lean.PrettyPrinter.ppTerm stx IO.println fmt.pretty
-/

-- lake env lean --run tools/reformat.lean LeanFormatterLab/FailurePattern.lean > LeanFormatterLab/FailurePatternFormatted.lean
def test : IO Unit := do
  let p := ((#[] : Array Nat), #[1, 2])
  -- 2.doになってやっぱり壊れる
  for x in p.2do
    IO.println x


