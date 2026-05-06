import Lean

#eval do
  let stx ← `(term| ``x)
  let fmt ← Lean.PrettyPrinter.ppTerm stx
  IO.println fmt.pretty

#eval do
  let stx ← `(term|  ``Parser.Module.header)
  let fmt ← Lean.PrettyPrinter.ppTerm stx
  IO.println fmt.pretty

def test : IO Unit := do
  let p := ((#[] : Array Nat), #[1, 2])
  for x in p.2 do
    IO.println x
