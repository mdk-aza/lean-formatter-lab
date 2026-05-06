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

def makeSourceViewerData
    (termStr phase2Str phase4Str tree1Json tree3Json : String) : String :=
  "window.LEAN_DATA={" ++
  s!"term:\"{escapeJson termStr}\"," ++
  s!"phase2:\"{escapeJson phase2Str}\"," ++
  s!"phase4:\"{escapeJson phase4Str}\"," ++
  s!"tree1:{tree1Json}," ++
  s!"tree3:{tree3Json}" ++
  "};"

def writeSourceViewerHtml
    (termStr phase2Str phase4Str tree1Json tree3Json : String)
    (outPath : String := "lean_source_viewer_v2.html") : IO Unit := do
  let data := makeSourceViewerData termStr phase2Str phase4Str tree1Json tree3Json
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

    let delab_t ← PrettyPrinter.delab e
    let tree3Json := syntaxToJsonWithRange base delab_t

    let fmt ← PrettyPrinter.ppTerm delab_t
    let phase4Str := fmt.pretty

    liftM (writeSourceViewerHtml termStr phase2Str phase4Str tree1Json tree3Json)
    logInfo m!"✓ lean_source_viewer_v2.html を生成しました。ブラウザで開いてください。"

end LeanFormatterLab
