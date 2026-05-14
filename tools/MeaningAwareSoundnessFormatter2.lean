import Lean

open Lean Elab Meta PrettyPrinter

/-
=========================================================
データ構造
=========================================================
-/

structure CommandSemantic where
  stx   : Syntax
  exprs : Array Expr

structure CheckResult where
  strictOk : Bool
  defEqOk  : Bool


/-
=========================================================
ANSIカラー
=========================================================
-/

def green (s : String) := "\x1b[32m" ++ s ++ "\x1b[0m"
def red   (s : String) := "\x1b[31m" ++ s ++ "\x1b[0m"


/-
=========================================================
CSTフォールバック
=========================================================
-/

partial def formatSyntaxCST : Syntax → Format
  | Syntax.missing => ""
  | Syntax.atom _ val => val.trimAscii.toString
  | Syntax.ident _ raw _ _ => raw.toString
  | Syntax.node _ _ args =>
      Format.joinSep (args.toList.map formatSyntaxCST) " "


/-
=========================================================
:= 分割
=========================================================
-/

partial def splitAtAssign (xs : List Syntax) :
  List Syntax × List Syntax :=
  match xs with
  | [] => ([], [])
  | x :: xs =>
      match x with
      | Syntax.atom _ val =>
          if val == ":=" then
            ([], xs)
          else
            let (l, r) := splitAtAssign xs
            (x :: l, r)
      | _ =>
          let (l, r) := splitAtAssign xs
          (x :: l, r)


/-
=========================================================
PrettyPrinter（安全）
=========================================================
-/

def ppSafe (stx : Syntax) : CoreM Format := do
  try
    let fmt ← PrettyPrinter.ppCommand ⟨stx⟩
    return fmt.pretty
  catch _ =>
    return (formatSyntaxCST stx).pretty


/-
=========================================================
defフォーマット
=========================================================
-/

def formatDefLikeM (stx : Syntax) : CoreM Format := do
  match stx with
  | Syntax.node _ _ args =>
      let parts := args.toList
      let (lhs, rhs) := splitAtAssign parts

      if rhs.isEmpty then
        -- 修正1: mapにラムダ式を使い、セパレータの型(" " : Format)を明示
        return Format.joinSep (parts.map (fun s => formatSyntaxCST s)) (" " : Format)
      else
        -- 修正1: 同上
        let lhsFmt := Format.joinSep (lhs.map (fun s => formatSyntaxCST s)) (" " : Format)

        let rhsStx := Syntax.node SourceInfo.none `Lean.Parser.Term.term rhs.toArray

        let rhsFmt ← ppSafe rhsStx

        -- 修正2: returnのパースエラーを防ぐため、一旦 let で受け取る
        let finalFmt := Format.group <|
          lhsFmt ++ (" :=" : Format) ++ Format.line ++ Format.nest 2 rhsFmt

        return finalFmt

  | _ =>
      return formatSyntaxCST stx


/-
=========================================================
unsafe判定
=========================================================
-/

partial def hasKeyword (kw : String) : Syntax → Bool
  | Syntax.atom _ val => val == kw
  | Syntax.node _ _ args => args.any (hasKeyword kw)
  | _ => false

def isSyntaxUnsafe (stx : Syntax) : Bool :=
  hasKeyword "by" stx ||
  hasKeyword "if" stx ||
  hasKeyword "do" stx ||
  hasKeyword "notation" stx

partial def hasInferInstance : Syntax → Bool
  | Syntax.ident _ _ val _ => val == `inferInstance
  | Syntax.node _ _ args => args.any hasInferInstance
  | _ => false

partial def exprHasInferInstance : Expr → Bool
  | Expr.const name _ => name == ``inferInstance
  | Expr.app f x => exprHasInferInstance f || exprHasInferInstance x
  | Expr.lam _ _ b _ => exprHasInferInstance b
  | Expr.forallE _ _ b _ => exprHasInferInstance b
  | Expr.letE _ _ v b _ => exprHasInferInstance v || exprHasInferInstance b
  | _ => false

partial def containsInstanceKeyword : Syntax → Bool
  | Syntax.atom _ val => val == "instance"
  | Syntax.node _ _ args => args.any containsInstanceKeyword
  | _ => false

def isSemanticUnsafe (cmd : CommandSemantic) : Bool :=
  containsInstanceKeyword cmd.stx ||
  hasInferInstance cmd.stx ||
  cmd.exprs.any exprHasInferInstance

def isUnsafe (cmd : CommandSemantic) : Bool :=
  isSyntaxUnsafe cmd.stx || isSemanticUnsafe cmd


/-
=========================================================
フォーマット
=========================================================
-/

def formatCommandM (cmd : CommandSemantic) : CoreM String := do
  if isUnsafe cmd then
    return red ("[UNSAFE] " ++ Format.pretty (formatSyntaxCST cmd.stx))
  else
    let fmt ← formatDefLikeM cmd.stx
    return green ("[SAFE] " ++ Format.pretty fmt)


/-
=========================================================
InfoTree → Expr
=========================================================
-/

partial def collectExprsFromInfoTree : InfoTree → Array Expr
  | InfoTree.context _ child =>
      collectExprsFromInfoTree child
  | InfoTree.node info children =>
      let self :=
        match info with
        | Info.ofTermInfo ti => #[ti.expr]
        | Info.ofDelabTermInfo ti => #[ti.expr]
        | _ => #[]
      let cs := children.foldl (fun acc c => acc ++ collectExprsFromInfoTree c) #[]
      self ++ cs
  | _ => #[]

def collectCommands (input : String) (fileName : String)
    : IO (Array CommandSemantic × Environment) := do

  let inputCtx := Parser.mkInputContext input fileName
  let (header, parserState, messages) ← Parser.parseHeader inputCtx
  let (env, messages) ← processHeader header {} messages inputCtx
  let env := env.setMainModule Name.anonymous

  let s ← IO.processCommands inputCtx parserState
    { Command.mkState env messages {} with
      infoState := { enabled := true } }

  let trees := s.commandState.infoState.trees.toArray

  let cmds ← trees.mapM fun tree => do
    let exprs := collectExprsFromInfoTree tree
    match tree with
    | InfoTree.context (PartialContextInfo.commandCtx _)
        (InfoTree.node (Info.ofCommandInfo info) _) =>
          return { stx := info.stx, exprs := exprs }
    | _ =>
          return { stx := Syntax.missing, exprs := exprs }

  return (cmds, s.commandState.env)


/-
=========================================================
defEqチェック
=========================================================
-/

def checkDefEq (e1 e2 : Expr) : MetaM Bool := do
  try isDefEq e1 e2 catch _ => return true

def checkExpr (before after : Array Expr) : MetaM CheckResult := do
  let strict :=
    before.size == after.size &&
    List.all (List.zip before.toList after.toList)
      (fun (e1, e2) => e1 == e2)

  let mut ok := true
  for (e1, e2) in List.zip before.toList after.toList do
    let same ← checkDefEq e1 e2
    if !same then ok := false

  return { strictOk := strict, defEqOk := ok }


/-
=========================================================
MetaM実行
=========================================================
-/

def runMetaM (env : Environment) (x : MetaM α) : IO α := do
  let coreCtx : Core.Context := {
    fileName     := "<run>",
    fileMap      := default,
    options      := {},
    currRecDepth := 0
  }
  let coreState : Core.State := { env }
  let eio := x.run' {} |>.run coreCtx coreState
  match (← eio.toBaseIO) with
  | Except.ok (result, _) => return result
  | Except.error e =>
      throw <| IO.userError (← e.toMessageData.toString)


/-
=========================================================
main
=========================================================
-/

unsafe def main (args : List String) : IO Unit := do
  let [fileName] := args
    | throw <| IO.userError "Usage: reformat <file>"

  initSearchPath (← findSysroot)

  let input ← IO.FS.readFile fileName
  let (cmds, env1) ← collectCommands input fileName

  let beforeExprs :=
    cmds.foldl (fun acc c => acc ++ c.exprs) #[]

  let mut out : Array String := #[]

  for cmd in cmds do
    let s ← runMetaM env1 (formatCommandM cmd)
    out := out.push s

  let newFile :=
    String.intercalate "\n" out.toList

  IO.println "====== FORMATTED CODE ======"
  IO.println newFile

  let (cmds2, _) ← collectCommands newFile fileName

  let afterExprs :=
    cmds2.foldl (fun acc c => acc ++ c.exprs) #[]

  let res ← runMetaM env1 (checkExpr beforeExprs afterExprs)

  IO.println "====== RESULT ======"
  IO.println s!"Strict: {res.strictOk}"
  IO.println s!"DefEq: {res.defEqOk}"