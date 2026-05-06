import Lean

namespace LeanFormatterLab

open Lean Meta Elab Term Command

-- ============================================================
-- Basic utilities
-- ============================================================

-- Option Nat をログ表示用の文字列に変換する。
-- SourceInfo がない場合は null と表示する。
def optNatToString : Option Nat → String
  | some n => toString n
  | none   => "null"

-- Lean の SourceInfo はファイル全体に対する byte offset を持つ。
-- この関数では、ある base position からの相対位置に変換する。
--
-- 例:
--   term 全体がファイル上の byte 100 から始まるとき、
--   token が byte 105 にあれば、relative position は 5 になる。
def relByteIdx? (base : Nat) (p? : Option α) (getByteIdx : α → Nat) : Option Nat :=
  p?.map fun p =>
    let i := getByteIdx p
    if i >= base then
      i - base
    else
      0

-- Syntax node の開始位置を、term 全体の開始位置からの相対 byte offset として取得する。
def stxStart? (base : Nat) (stx : Syntax) : Option Nat :=
  relByteIdx? base stx.getPos? (fun p => p.byteIdx)

-- Syntax node の終了位置を、term 全体の開始位置からの相対 byte offset として取得する。
def stxEnd? (base : Nat) (stx : Syntax) : Option Nat :=
  relByteIdx? base stx.getTailPos? (fun p => p.byteIdx)

-- SourceInfo の範囲を "start..end" の形で表示する。
--
-- 例:
--   2..7
--   null..null
def stxRangeString (base : Nat) (stx : Syntax) : String :=
  s!"{optNatToString (stxStart? base stx)}..{optNatToString (stxEnd? base stx)}"

-- ログ出力用のインデントを作る。
def indent (n : Nat) : String :=
  String.ofList (List.replicate n ' ')

-- Syntax node の種類を短く表示する。
--
-- 例:
--   node Lean.Parser.Term.paren
--   atom "+"
--   ident x
def syntaxHeadString (stx : Syntax) : String :=
  match stx with
  | .node _ kind _   => s!"node {kind}"
  | .atom _ val      => s!"atom \"{val}\""
  | .ident _ _ val _ => s!"ident {val}"
  | .missing         => "missing"

-- Syntax tree dump 用に、node の種類と子の数も含めて表示する。
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

-- ============================================================
-- Pretty printing Expr safely
-- ============================================================

-- Expr を表示用文字列に変換する。
--
-- InfoTree 内の Expr は、その時点の LocalContext のもとで表示する必要がある。
-- そのため ti.lctx を withLCtx で一時的にセットして ppExpr する。
--
-- 失敗した場合はツール全体を止めず、"<expr unavailable>" と表示する。
def ppExprSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let fmt ← ppExpr e
      pure fmt.pretty
  catch _ =>
    pure "<expr unavailable>"

-- Expr の型を推論し、表示用文字列に変換する。
--
-- これも LocalContext が必要になる場合があるため、ti.lctx の下で inferType する。
def ppTypeSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let ty ← inferType e
      let fmt ← ppExpr ty
      pure fmt.pretty
  catch _ =>
    pure "<type unavailable>"

-- expected type が存在する場合に表示する。
--
-- expected type は elaboration 時に「この term はこの型であることが期待されていた」
-- という情報で、型推論や暗黙引数の挿入を観察するときに有用。
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

-- ============================================================
-- Surface Syntax tree dump
-- ============================================================

-- Surface Syntax tree をログ表示用の行配列に変換する。
--
-- 目的:
--   入力 term の surface-level syntax がどのような tree と SourceInfo を持つか確認する。
--
-- 例:
--   ((1 + 2))
--
-- では、paren, hygienicLParen, atom "(", atom "+", atom ")" などが見える。
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

-- ============================================================
-- InfoTree dump
-- ============================================================

-- InfoTree から TermInfo / DelabTermInfo を集め、ログ表示用の文字列にする。
--
-- InfoTree は Lean の elaborator が生成する情報木で、
-- VS Code の hover や Infoview の情報の元にもなる。
--
-- このツールで重要なのは TermInfo:
--
--   Source range
--     ↓
--   Syntax node
--     ↓
--   Elaborated Expr
--     ↓
--   Type / Expected type
--
-- という対応を観察できる。
--
-- 例えば `1 + 2` では、
--
--   range 2..7  node «term_+_»  expr=1+2  type=Nat
--   range 2..3  node num        expr=1    type=Nat
--   range 6..7  node num        expr=2    type=Nat
--
-- のような情報が得られる。
partial def collectTermInfoLines
    (base : Nat)
    (tree : InfoTree)
    (depth : Nat := 0) :
    TermElabM (Array String) := do

  match tree with
  | .context _ child =>
      -- context node は LocalContext などを保持するための wrapper。
      -- ここでは子を再帰的にたどる。
      collectTermInfoLines base child depth

  | .hole _ =>
      -- hole node には今回出したい TermInfo はないので無視する。
      pure #[]

  | .node info children =>
      let mut lines : Array String := #[]

      match info with
      | .ofTermInfo ti =>
          -- 通常の term elaboration で得られる情報。
          -- surface syntax と elaborated Expr / type の対応を見る中心。
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
          -- delaboration 側で得られる term info。
          -- 出る場合は、delab / pretty printing 側の情報を観察するのに使える。
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
          -- CommandInfo, TacticInfo, FieldInfo などは今回は出さない。
          pure ()

      -- 子の InfoTree を再帰的にたどる。
      for child in children do
        let childLines ← collectTermInfoLines base child (depth + 2)
        lines := lines ++ childLines

      pure lines

-- ============================================================
-- Command: #analyze_term_info
-- ============================================================

-- 使用例:
--
--   #analyze_term_info ((1 + 2))
--   #analyze_term_info (fun x : Nat => x + 1)
--
-- 入力 term の Surface Syntax, Elaborated Expr, Type, TermInfo をログ出力する。
-- syntax + @[command_elab]:
  -- syntax 定義と elaborator 登録を分けて書く明示的な方法
syntax (name := analyzeTermInfoCmd) "#analyze_term_info " term : command


@[command_elab analyzeTermInfoCmd]
def elabAnalyzeTermInfoCmd : CommandElab := fun stx => do
  match stx with
  | `(#analyze_term_info $t:term) =>
      Command.liftTermElabM do
        -- TSyntax `term` から raw Syntax を取り出す。
        -- SourceInfo や Syntax tree を見るときは raw を使う。
        -- ppTerm / elabTerm には t を使う。
        let raw : Syntax := t.raw

        -- SourceInfo はファイル全体に対する byte offset なので、
        -- 入力 term の開始位置を base として相対位置に変換する。
        let base : Nat :=
          match raw.getPos? with
          | some p => p.byteIdx
          | none   => 0

        -- 1. Surface term の概要を表示する。
        logInfo m!"=== Surface term ==="
        logInfo m!"term  : {(← PrettyPrinter.ppTerm t).pretty}"
        logInfo m!"range : {stxRangeString base raw}"
        logInfo m!"head  : {syntaxHeadString raw}"

        -- 2. Surface Syntax tree を表示する。
        --    括弧、notation、hygieneInfo、atom などがどのように入っているかを見る。
        let stxLines := syntaxTreeLines base raw
        logInfo m!"=== Surface Syntax Tree ===\n{String.intercalate "\n" stxLines.toList}"

        -- 3. term を elaboration して Expr を得る。
        --    ここで notation 展開、暗黙引数、型クラス解決などが行われる。
        let e ← elabTerm t none
        synthesizeSyntheticMVarsNoPostponing
        let e ← instantiateMVars e

        logInfo m!"=== Whole elaborated Expr ==="
        logInfo m!"{e}"

        -- 4. elaborated Expr 全体の型を表示する。
        let ty ← inferType e
        logInfo m!"=== Whole elaborated Expr type ==="
        logInfo m!"{← ppExpr ty}"

        -- 5. elaboration 中に生成された InfoTree を取得する。
        --    InfoTree から TermInfo を取り出すことで、
        --    source range と Expr / Type の対応を観察できる。
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