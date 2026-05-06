import Lean
import Lean.Widget.UserWidget
import LeanFormatterLab.SourceViewerHtml

namespace LeanFormatterLab

open Lean Meta Elab Term

private def escapeJson (s : String) : String :=
  s.foldl (fun acc c =>
    acc ++ match c with
      | '"'  => "\\\""
      | '\\' => "\\\\"
      | '\n' => "\\n"
      | '\r' => "\\r"
      | '\t' => "\\t"
      | c    => String.singleton c
  ) ""

private def optNatToJson : Option Nat → String
  | some n => toString n
  | none   => "null"

private def viewerRelByteIdx? (base : Nat) (p? : Option α) (getByteIdx : α → Nat) : Option Nat :=
  p?.map fun p =>
    let i := getByteIdx p
    if i >= base then
      i - base
    else
      0

private def syntaxStart? (base : Nat) (stx : Syntax) : Option Nat :=
  viewerRelByteIdx? base stx.getPos? (fun p => p.byteIdx)

private def syntaxEnd? (base : Nat) (stx : Syntax) : Option Nat :=
  viewerRelByteIdx? base stx.getTailPos? (fun p => p.byteIdx)

private def syntaxHeadString (stx : Syntax) : String :=
  match stx with
  | .node _ kind _   => s!"node {kind}"
  | .atom _ val      => s!"atom \"{val}\""
  | .ident _ _ val _ => s!"ident {val}"
  | .missing         => "missing"

partial def syntaxToJsonWithRange (base : Nat) : Syntax → String
  | stx@(.node _ kind args) =>
      let kids :=
        args.toList
          |>.map (syntaxToJsonWithRange base)
          |>.intersperse ","
          |>.foldl (· ++ ·) ""
      let start := syntaxStart? base stx
      let stop  := syntaxEnd? base stx
      s!"\{\"type\":\"node\",\"kind\":\"{escapeJson kind.toString}\",\"start\":{optNatToJson start},\"end\":{optNatToJson stop},\"children\":[{kids}]}"
  | stx@(.atom _ val) =>
      let start := syntaxStart? base stx
      let stop  := syntaxEnd? base stx
      s!"\{\"type\":\"atom\",\"val\":\"{escapeJson val}\",\"start\":{optNatToJson start},\"end\":{optNatToJson stop}}"
  | stx@(.ident _ _ val _) =>
      let start := syntaxStart? base stx
      let stop  := syntaxEnd? base stx
      s!"\{\"type\":\"ident\",\"val\":\"{escapeJson val.toString}\",\"start\":{optNatToJson start},\"end\":{optNatToJson stop}}"
  | _ =>
      "{\"type\":\"missing\",\"start\":null,\"end\":null}"

private def jsonField (k v : String) : String :=
  s!"\"{escapeJson k}\":\"{escapeJson v}\""

private def jsonOptNatField (k : String) (v : Option Nat) : String :=
  s!"\"{escapeJson k}\":{optNatToJson v}"

private def ppExprSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let fmt ← ppExpr e
      pure fmt.pretty
  catch _ =>
    pure "<expr unavailable>"

private def ppTypeSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let ty ← inferType e
      let fmt ← ppExpr ty
      pure fmt.pretty
  catch _ =>
    pure "<type unavailable>"

private def ppExpectedSafe (lctx : LocalContext) (expected? : Option Expr) : TermElabM String := do
  match expected? with
  | none => pure "none"
  | some expected =>
      try
        withLCtx lctx {} do
          let fmt ← ppExpr expected
          pure fmt.pretty
      catch _ =>
        pure "<expected type unavailable>"

private def termInfoJson
    (base : Nat)
    (kind : String)
    (stx : Syntax)
    (elaborator : Name)
    (exprStr typeStr expectedStr : String) : String :=
  let start := syntaxStart? base stx
  let stop  := syntaxEnd? base stx
  "{" ++
    jsonField "kind" kind ++ "," ++
    jsonField "syntax" (syntaxHeadString stx) ++ "," ++
    jsonField "elaborator" elaborator.toString ++ "," ++
    jsonField "expr" exprStr ++ "," ++
    jsonField "type" typeStr ++ "," ++
    jsonField "expected" expectedStr ++ "," ++
    jsonOptNatField "start" start ++ "," ++
    jsonOptNatField "end" stop ++
  "}"

partial def collectTermInfoJsonEntries
    (base : Nat)
    (tree : InfoTree)
    : TermElabM (Array String) := do
  match tree with
  | .context _ child =>
      collectTermInfoJsonEntries base child
  | .hole _ =>
      pure #[]
  | .node info children =>
      let mut entries : Array String := #[]
      match info with
      | .ofTermInfo ti =>
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?
          entries := entries.push
            (termInfoJson base "TermInfo" ti.stx ti.elaborator exprStr typeStr expectedStr)
      | .ofDelabTermInfo ti =>
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?
          entries := entries.push
            (termInfoJson base "DelabTermInfo" ti.stx ti.elaborator exprStr typeStr expectedStr)
      | _ =>
          pure ()
      for child in children do
        let childEntries ← collectTermInfoJsonEntries base child
        entries := entries ++ childEntries
      pure entries

def makeSourceViewerData
    (termStr phase2Str phase4Str tree1Json tree3Json termInfosJson : String) : String :=
  "window.LEAN_DATA={" ++
  s!"term:\"{escapeJson termStr}\"," ++
  s!"phase2:\"{escapeJson phase2Str}\"," ++
  s!"phase4:\"{escapeJson phase4Str}\"," ++
  s!"tree1:{tree1Json}," ++
  s!"tree3:{tree3Json}," ++
  s!"termInfos:{termInfosJson}" ++
  "};"

def writeSourceViewerHtml
    (termStr phase2Str phase4Str tree1Json tree3Json termInfosJson : String)
    (outPath : String := "lean_source_viewer_v2.html") : IO Unit := do
  let data := makeSourceViewerData termStr phase2Str phase4Str tree1Json tree3Json termInfosJson
  writeSourceViewerHtmlFile data outPath

elab "#analyze_term " t:term : command => do
  Command.liftTermElabM do
    let raw : Syntax := t.raw

    let base : Nat :=
      match raw.getPos? with
      | some p => p.byteIdx
      | none   => 0

    let tree1Json := syntaxToJsonWithRange base raw
    let termStr   := (← PrettyPrinter.ppTerm t).pretty

    let e ← elabTerm t none
    synthesizeSyntheticMVarsNoPostponing
    let e ← instantiateMVars e
    let phase2Str := toString e

    let infoState ← getInfoState
    let mut termInfoEntries : Array String := #[]
    for tree in infoState.trees do
      let entries ← collectTermInfoJsonEntries base tree
      termInfoEntries := termInfoEntries ++ entries
    let termInfosJson :=
      "[" ++ String.intercalate "," termInfoEntries.toList ++ "]"

    let delab_t ← PrettyPrinter.delab e
    let tree3Json := syntaxToJsonWithRange base delab_t

    let fmt ← PrettyPrinter.ppTerm delab_t
    let phase4Str := fmt.pretty

    liftM (writeSourceViewerHtml termStr phase2Str phase4Str tree1Json tree3Json termInfosJson)
    logInfo m!"✓ lean_source_viewer_v2.html を生成しました。ブラウザで開いてください。"

end LeanFormatterLab
