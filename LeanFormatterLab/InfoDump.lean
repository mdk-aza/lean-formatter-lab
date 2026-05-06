import Lean

namespace LeanFormatterLab

open Lean Meta Elab Term Command

def optNatToString : Option Nat → String
  | some n => toString n
  | none   => "null"

def relByteIdx? (base : Nat) (p? : Option α) (getByteIdx : α → Nat) : Option Nat :=
  p?.map fun p =>
    let i := getByteIdx p
    if i >= base then
      i - base
    else
      0

def stxStart? (base : Nat) (stx : Syntax) : Option Nat :=
  relByteIdx? base stx.getPos? (fun p => p.byteIdx)

def stxEnd? (base : Nat) (stx : Syntax) : Option Nat :=
  relByteIdx? base stx.getTailPos? (fun p => p.byteIdx)

def stxRangeString (base : Nat) (stx : Syntax) : String :=
  s!"{optNatToString (stxStart? base stx)}..{optNatToString (stxEnd? base stx)}"

def indent (n : Nat) : String :=
  String.ofList (List.replicate n ' ')

def syntaxHeadString (stx : Syntax) : String :=
  match stx with
  | .node _ kind _   => s!"node {kind}"
  | .atom _ val      => s!"atom \"{val}\""
  | .ident _ _ val _ => s!"ident {val}"
  | .missing         => "missing"

def syntaxBriefString (stx : Syntax) : String :=
  match stx with
  | .node _ kind args =>
      s!"node {kind} / children={args.size}"
  | .atom _ val =>
      s!"atom \"{val}\""
  | .ident _ _ val _ =>
      s!"ident {val}"
  | .missing =>
      "missing"

def ppExprSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let fmt ← ppExpr e
      pure fmt.pretty
  catch _ =>
    pure "<expr unavailable>"

def ppTypeSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let ty ← inferType e
      let fmt ← ppExpr ty
      pure fmt.pretty
  catch _ =>
    pure "<type unavailable>"

def ppExpectedSafe (lctx : LocalContext) (expected? : Option Expr) :
    TermElabM String := do
  match expected? with
  | none =>
      pure "none"
  | some expected =>
      try
        withLCtx lctx {} do
          let fmt ← ppExpr expected
          pure fmt.pretty
      catch _ =>
        pure "<expected type unavailable>"

partial def syntaxTreeLines
    (base : Nat)
    (stx : Syntax)
    (depth : Nat := 0) :
    Array String :=
  let pad := indent depth
  let head := syntaxBriefString stx
  let range := stxRangeString base stx
  let current := s!"{pad}{head}  range={range}"
  match stx with
  | .node _ _ args =>
      args.foldl
        (fun acc child => acc ++ syntaxTreeLines base child (depth + 2))
        #[current]
  | _ =>
      #[current]

partial def collectTermInfoLines
    (base : Nat)
    (tree : InfoTree)
    (depth : Nat := 0) :
    TermElabM (Array String) := do

  match tree with
  | .context _ child =>
      collectTermInfoLines base child depth

  | .hole _ =>
      pure #[]

  | .node info children =>
      let mut lines : Array String := #[]

      match info with
      | .ofTermInfo ti =>
          let stx := ti.stx
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?

          let line :=
            s!"{indent depth}TermInfo\n" ++
            s!"{indent depth}  range     : {stxRangeString base stx}\n" ++
            s!"{indent depth}  syntax    : {syntaxHeadString stx}\n" ++
            s!"{indent depth}  elaborator: {ti.elaborator}\n" ++
            s!"{indent depth}  expr      : {exprStr}\n" ++
            s!"{indent depth}  type      : {typeStr}\n" ++
            s!"{indent depth}  expected  : {expectedStr}"

          lines := lines.push line

      | .ofDelabTermInfo ti =>
          let stx := ti.stx
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?

          let line :=
            s!"{indent depth}DelabTermInfo\n" ++
            s!"{indent depth}  range     : {stxRangeString base stx}\n" ++
            s!"{indent depth}  syntax    : {syntaxHeadString stx}\n" ++
            s!"{indent depth}  elaborator: {ti.elaborator}\n" ++
            s!"{indent depth}  expr      : {exprStr}\n" ++
            s!"{indent depth}  type      : {typeStr}\n" ++
            s!"{indent depth}  expected  : {expectedStr}"

          lines := lines.push line

      | _ =>
          pure ()

      for child in children do
        let childLines ← collectTermInfoLines base child (depth + 2)
        lines := lines ++ childLines

      pure lines

syntax (name := analyzeTermInfoCmd) "#analyze_term_info " term : command

@[command_elab analyzeTermInfoCmd]
def elabAnalyzeTermInfoCmd : CommandElab := fun stx => do
  match stx with
  | `(#analyze_term_info $t:term) =>
      Command.liftTermElabM do
        let raw : Syntax := t.raw

        let base : Nat :=
          match raw.getPos? with
          | some p => p.byteIdx
          | none   => 0

        logInfo m!"=== Surface term ==="
        logInfo m!"term  : {(← PrettyPrinter.ppTerm t).pretty}"
        logInfo m!"range : {stxRangeString base raw}"
        logInfo m!"head  : {syntaxHeadString raw}"

        let stxLines := syntaxTreeLines base raw
        logInfo m!"=== Surface Syntax Tree ===\n{String.intercalate "\n" stxLines.toList}"

        let e ← elabTerm t none
        synthesizeSyntheticMVarsNoPostponing
        let e ← instantiateMVars e

        logInfo m!"=== Whole elaborated Expr ==="
        logInfo m!"{e}"

        let ty ← inferType e
        logInfo m!"=== Whole elaborated Expr type ==="
        logInfo m!"{← ppExpr ty}"

        let infoState ← getInfoState
        let mut allLines : Array String := #[]

        for tree in infoState.trees do
          let lines ← collectTermInfoLines base tree
          allLines := allLines ++ lines

        if allLines.isEmpty then
          logInfo m!"=== TermInfo nodes ===\nNo TermInfo found."
        else
          logInfo m!"=== TermInfo nodes ===\n{String.intercalate "\n\n" allLines.toList}"

  | _ =>
      throwUnsupportedSyntax

end LeanFormatterLab