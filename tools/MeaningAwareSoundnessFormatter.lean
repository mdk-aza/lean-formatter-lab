import Lean

open Lean Elab Meta Term

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
  基本フォーマット
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
  def系フォーマット
  =========================================================
-/

def formatDefLike (stx : Syntax) : Format :=
  match stx with
  | Syntax.node _ _ args =>
      let parts := args.toList

      let rec split xs :=
        match xs with
        | [] => ([], none, [])
        | x :: xs =>
            match x with
            | Syntax.atom _ ":=" => ([], some x, xs)
            | _ =>
                let (l, mid, r) := split xs
                (x :: l, mid, r)

      let (lhs, mid?, rhs) := split parts

      match mid? with
      | none =>
          Format.joinSep (parts.map formatSyntaxCST) " "

      | some _ =>
          let lhsFmt :=
            Format.joinSep (lhs.map formatSyntaxCST) " "

          let rhsFmt :=
            Format.joinSep (rhs.map formatSyntaxCST) " "

          Format.group <|
            lhsFmt ++
            " :=" ++
            Format.line ++
            Format.nest 2 rhsFmt

  | _ => formatSyntaxCST stx


/-
  =========================================================
  unsafe判定
  =========================================================
-/

partial def hasBy : Syntax → Bool
  | Syntax.atom _ "by" => true
  | Syntax.node _ _ args => args.any hasBy
  | _ => false

partial def hasIf : Syntax → Bool
  | Syntax.atom _ "if" => true
  | Syntax.node _ _ args => args.any hasIf
  | _ => false

partial def hasDo : Syntax → Bool
  | Syntax.atom _ "do" => true
  | Syntax.node _ _ args => args.any hasDo
  | _ => false

def isSyntaxUnsafe (stx : Syntax) : Bool :=
  hasBy stx || hasIf stx || hasDo stx

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
  フォーマット（カラー対応）
  =========================================================
-/

def formatCommand (cmd : CommandSemantic) : String :=
  if isUnsafe cmd then
    red ("[UNSAFE] " ++ Format.pretty (formatSyntaxCST cmd.stx))
  else
    green ("[SAFE] " ++ Format.pretty (formatDefLike cmd.stx))


/-
  =========================================================
  InfoTree
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

partial def hasFVar : Expr → Bool
  | Expr.fvar _          => true
  | Expr.app f x         => hasFVar f || hasFVar x
  | Expr.lam _ t b _     => hasFVar t || hasFVar b
  | Expr.forallE _ t b _ => hasFVar t || hasFVar b
  | Expr.letE _ t v b _  => hasFVar t || hasFVar v || hasFVar b
  | _ => false

partial def hasMVar : Expr → Bool
  | Expr.mvar _          => true
  | Expr.app f x         => hasMVar f || hasMVar x
  | Expr.lam _ t b _     => hasMVar t || hasMVar b
  | Expr.forallE _ t b _ => hasMVar t || hasMVar b
  | Expr.letE _ t v b _  => hasMVar t || hasMVar v || hasMVar b
  | _ => false

def checkDefEq (e1 e2 : Expr) : MetaM Bool := do
  if hasFVar e1 || hasFVar e2 then return true
  if hasMVar e1 || hasMVar e2 then return true
  try isDefEq e1 e2 catch _ => return true

def checkDefEqs (before after : Array Expr) : MetaM Bool := do
  if before.size != after.size then return false
  let mut ok := true
  for (e1, e2) in List.zip before.toList after.toList do
    let same ← checkDefEq e1 e2
    if !same then ok := false
  return ok

def checkExpr (before after : Array Expr) : MetaM CheckResult := do
  let strict :=
    before.size == after.size &&
    List.all (List.zip before.toList after.toList)
      (fun (e1, e2) => e1 == e2)

  let defEqOk ← checkDefEqs before after
  return { strictOk := strict, defEqOk := defEqOk }


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
  let eio : EIO Exception (α × Core.State) :=
    x.run' {} |>.run coreCtx coreState
  match (← eio.toBaseIO) with
  | Except.ok (result, _) => return result
  | Except.error e        =>
      let msg ← e.toMessageData.toString
      throw <| IO.userError msg


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

  let newFile :=
    String.intercalate "\n"
      (cmds.map formatCommand |>.toList)

  IO.println "====== FORMATTED CODE ======"
  IO.println newFile

  let (cmds2, _) ← collectCommands newFile fileName

  let afterExprs :=
    cmds2.foldl (fun acc c => acc ++ c.exprs) #[]

  let res ← runMetaM env1 (checkExpr beforeExprs afterExprs)

  IO.println "====== RESULT ======"
  IO.println s!"Strict: {res.strictOk}"
  IO.println s!"DefEq: {res.defEqOk}"