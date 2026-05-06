import Lean
import Lean.Widget.UserWidget
import LeanFormatterLab.SourceViewerHtml

namespace LeanFormatterLab

open Lean Meta Elab Term

-- ============================================================
-- JSON utilities
-- ============================================================

-- Lean 側で作った文字列を JavaScript の JSON 文字列として安全に埋め込むための escape。
--
-- 例:
--   "      -> \"
--   \      -> \\
--   改行   -> \n
--
-- これをしないと、Expr や Syntax の表示文字列に引用符や改行が含まれたときに、
-- 生成される HTML / JavaScript が壊れる。
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

-- Option Nat を JSON 値として出力する。
--
-- some n -> n
-- none   -> null
--
-- SourceInfo が存在しない場合、Viewer 側では null として扱う。
private def optNatToJson : Option Nat → String
  | some n => toString n
  | none   => "null"

-- Lean の SourceInfo はファイル全体に対する byte offset を持つ。
-- Viewer では入力 term の先頭を 0 として見たいので、base からの相対位置に変換する。
--
-- getByteIdx を引数にしているのは、String.Pos などの型名に直接依存しないため。
private def viewerRelByteIdx? (base : Nat) (p? : Option α) (getByteIdx : α → Nat) : Option Nat :=
  p?.map fun p =>
    let i := getByteIdx p
    if i >= base then
      i - base
    else
      0

-- Syntax node の開始位置を、入力 term 先頭からの相対 byte offset として取得する。
private def syntaxStart? (base : Nat) (stx : Syntax) : Option Nat :=
  viewerRelByteIdx? base stx.getPos? (fun p => p.byteIdx)

-- Syntax node の終了位置を、入力 term 先頭からの相対 byte offset として取得する。
private def syntaxEnd? (base : Nat) (stx : Syntax) : Option Nat :=
  viewerRelByteIdx? base stx.getTailPos? (fun p => p.byteIdx)

-- Viewer に表示するための Syntax node の短い説明。
--
-- 例:
--   node Lean.Parser.Term.paren
--   atom "+"
--   ident x
private def syntaxHeadString (stx : Syntax) : String :=
  match stx with
  | .node _ kind _   => s!"node {kind}"
  | .atom _ val      => s!"atom \"{val}\""
  | .ident _ _ val _ => s!"ident {val}"
  | .missing         => "missing"

-- ============================================================
-- Surface / Delaborated Syntax JSON
-- ============================================================

-- Syntax tree を Viewer 用 JSON に変換する。
--
-- 各 node には以下を持たせる:
--   type     : "node" / "atom" / "ident" / "missing"
--   kind/val : Syntax kind または token value
--   start/end: SourceInfo の相対範囲
--   children : 子ノード
--
-- Surface Syntax では start/end が入りやすい。
-- 一方、delab で再構成された Syntax では start/end が null になりやすい。
-- これが「元の source range は delaboration 後には保存されにくい」
-- という観察の根拠になる。
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

-- ============================================================
-- TermInfo JSON utilities
-- ============================================================

-- JSON の文字列フィールドを作る。
--
-- 例:
--   jsonField "expr" "1 + 2"
--   -> "\"expr\":\"1 + 2\""
private def jsonField (k v : String) : String :=
  s!"\"{escapeJson k}\":\"{escapeJson v}\""

-- JSON の Option Nat フィールドを作る。
--
-- 例:
--   jsonOptNatField "start" (some 2) -> "\"start\":2"
--   jsonOptNatField "start" none     -> "\"start\":null"
private def jsonOptNatField (k : String) (v : Option Nat) : String :=
  s!"\"{escapeJson k}\":{optNatToJson v}"

-- ============================================================
-- Pretty printing Expr safely
-- ============================================================

-- InfoTree 内の Expr を文字列化する。
--
-- TermInfo の Expr は、その時点の LocalContext のもとで表示する必要がある。
-- そのため ti.lctx を withLCtx でセットして ppExpr する。
--
-- 失敗しても Viewer 全体を壊さないように、代替文字列を返す。
private def ppExprSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let fmt ← ppExpr e
      pure fmt.pretty
  catch _ =>
    pure "<expr unavailable>"

-- Expr の型を推論し、文字列化する。
--
-- Viewer の Metadata Panel で、
--   expr=1
--   type=Nat
-- のように表示するために使う。
private def ppTypeSafe (lctx : LocalContext) (e : Expr) : TermElabM String := do
  try
    withLCtx lctx {} do
      let ty ← inferType e
      let fmt ← ppExpr ty
      pure fmt.pretty
  catch _ =>
    pure "<type unavailable>"

-- expected type を文字列化する。
--
-- expected type は elaborator が「この term はこの型であるはず」と期待していた型。
-- 型注釈、省略、暗黙引数の観察に役立つ。
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

-- 1つの TermInfo / DelabTermInfo を Viewer 用 JSON にする。
--
-- kind:
--   "TermInfo" または "DelabTermInfo"
--
-- JSON に含めるもの:
--   source range
--   syntax kind
--   elaborator 名
--   expr
--   type
--   expected type
--
-- これにより Viewer 側で、
-- token range に対応する InfoTree / Expr / Type を表示できる。
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

-- InfoTree 全体から TermInfo / DelabTermInfo を集め、JSON entry の配列にする。
--
-- InfoTree は elaboration 中に生成される情報木。
-- VS Code の hover / infoview の元にもなる。
--
-- この Viewer では、Source token の start/end と TermInfo の start/end を比較し、
-- 「この token に対応する Expr / Type は何か」を表示するために使う。
partial def collectTermInfoJsonEntries
    (base : Nat)
    (tree : InfoTree)
    : TermElabM (Array String) := do
  match tree with
  | .context _ child =>
      -- context node は wrapper なので、子をたどる。
      collectTermInfoJsonEntries base child

  | .hole _ =>
      -- hole には今回は表示したい情報がないので無視。
      pure #[]

  | .node info children =>
      let mut entries : Array String := #[]

      match info with
      | .ofTermInfo ti =>
          -- Surface Syntax と elaborated Expr / Type の対応を見る中心。
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?
          entries := entries.push
            (termInfoJson base "TermInfo" ti.stx ti.elaborator exprStr typeStr expectedStr)

      | .ofDelabTermInfo ti =>
          -- delaboration 側の TermInfo。
          -- 得られる場合は、delab / pretty printing 側の情報観察に使える。
          let exprStr ← ppExprSafe ti.lctx ti.expr
          let typeStr ← ppTypeSafe ti.lctx ti.expr
          let expectedStr ← ppExpectedSafe ti.lctx ti.expectedType?
          entries := entries.push
            (termInfoJson base "DelabTermInfo" ti.stx ti.elaborator exprStr typeStr expectedStr)

      | _ =>
          -- CommandInfo, TacticInfo などは現段階では扱わない。
          pure ()

      -- 子の InfoTree も再帰的に処理する。
      for child in children do
        let childEntries ← collectTermInfoJsonEntries base child
        entries := entries ++ childEntries

      pure entries

-- ============================================================
-- Viewer data generation
-- ============================================================

-- HTML 内に埋め込む JavaScript データを生成する。
--
-- 生成される形:
--
--   window.LEAN_DATA = {
--     term: ...,
--     phase2: ...,
--     phase4: ...,
--     tree1: ...,
--     tree3: ...,
--     termInfos: ...
--   };
--
-- Viewer 側の JavaScript はこの LEAN_DATA を読んで、
-- Annotated Source, Metadata Panel, Focus Graph を描画する。
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

-- Viewer 用の HTML ファイルを書き出す。
--
-- HTML/CSS/JS のテンプレート本体は SourceViewerHtml.lean に分離している。
-- このファイルでは Lean 側でデータを作り、テンプレートへ渡すだけにする。
def writeSourceViewerHtml
    (termStr phase2Str phase4Str tree1Json tree3Json termInfosJson : String)
    (outPath : String := "lean_source_viewer_v2.html") : IO Unit := do
  let data := makeSourceViewerData termStr phase2Str phase4Str tree1Json tree3Json termInfosJson
  writeSourceViewerHtmlFile data outPath

-- ============================================================
-- Command: #analyze_term
-- ============================================================

-- 使用例:
--
--   #analyze_term ((1 + 2))
--   #analyze_term (fun x : Nat => x + 1)
--   #analyze_term (let x := 1; x + 2)
--
-- このコマンドは次の情報を収集し、HTML Viewer を生成する:
--
--   1. Surface Syntax tree + SourceInfo
--   2. Elaborated Expr
--   3. InfoTree / TermInfo / Expr / Type
--   4. Delaborated Syntax tree
--   5. Pretty printed text
--
-- 目的:
--   Lean の elaboration / delaboration pipeline において、
--   source-level information がどのように保存・吸収・再構成・消失するかを
--   観察する。

 -- elab Leanへのコマンド追加
 -- elab "...":
   -- syntax 定義と elaborator 登録をまとめて書ける簡単な方法
elab "#analyze_term " t:term : command => do
  Command.liftTermElabM do
    -- TSyntax `term` から raw Syntax を取り出す。
    --
    -- raw:
    --   SourceInfo や Syntax tree を見るために使う。
    --
    -- t:
    --   ppTerm / elabTerm に渡すために使う。
    let raw : Syntax := t.raw

    -- SourceInfo の base を決める。
    -- ファイル全体に対する byte offset ではなく、
    -- 入力 term の先頭を 0 とする相対位置に変換するため。
    let base : Nat :=
      match raw.getPos? with
      | some p => p.byteIdx
      | none   => 0

    -- 1. Surface Syntax を JSON 化する。
    --    ここには元ソースの SourceInfo が入りやすい。
    let tree1Json := syntaxToJsonWithRange base raw

    -- 表示用の入力 term 文字列。
    let termStr   := (← PrettyPrinter.ppTerm t).pretty

    -- 2. Elaboration: Surface term を Expr に変換する。
    --
    -- ここで notation 展開、型推論、暗黙引数、型クラス解決などが行われる。
    let e ← elabTerm t none
    synthesizeSyntheticMVarsNoPostponing
    let e ← instantiateMVars e

    -- Elaborated Expr 全体を表示用文字列にする。
    let phase2Str := toString e

    -- 3. InfoTree / TermInfo を JSON 化する。
    --
    -- InfoTree は elabTerm によって生成された情報を含む。
    -- Source token の range と TermInfo の range を Viewer 側で対応づけることで、
    -- token -> Expr / Type の関係を表示できる。
    let infoState ← getInfoState
    let mut termInfoEntries : Array String := #[]
    for tree in infoState.trees do
      let entries ← collectTermInfoJsonEntries base tree
      termInfoEntries := termInfoEntries ++ entries
    let termInfosJson :=
      "[" ++ String.intercalate "," termInfoEntries.toList ++ "]"

    -- 4. Delaboration: Expr から表示用 Syntax を再構成する。
    --
    -- 重要:
    --   delab_t は元の surface syntax を復元したものではなく、
    --   Expr から人間向けに再構成された Syntax。
    --
    --   そのため SourceInfo は null になりやすい。
    let delab_t ← PrettyPrinter.delab e
    let tree3Json := syntaxToJsonWithRange base delab_t

    -- 5. Pretty printing: Delaborated Syntax を最終的な表示文字列にする。
    let fmt ← PrettyPrinter.ppTerm delab_t
    let phase4Str := fmt.pretty

    -- 6. HTML Viewer を生成する。
    liftM (writeSourceViewerHtml termStr phase2Str phase4Str tree1Json tree3Json termInfosJson)
    logInfo m!"✓ lean_source_viewer_v2.html を生成しました。ブラウザで開いてください。"

end LeanFormatterLab