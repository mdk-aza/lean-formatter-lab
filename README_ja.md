# Lean Formatter Lab

[![Lean](https://img.shields.io/badge/Lean-4-blue)](https://leanprover.github.io/)
[![Status](https://img.shields.io/badge/status-in_progress-yellow)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

本リポジトリは、Lean 4 における**意味保存的なコードフォーマッター**の研究および開発のための実験環境（ラボ）です。

**多段階計算（Multi-stage computation）**によって生じる、エラボレーション過程でのコメント、空白、特定の記法（notation）の喪失という課題を解決するための学術的アプローチを試行しています。

---

## 🎯 目的

- **「理論の壁」の調査**: 従来の言語と比較して、なぜ Lean 4 のフォーマッター構築が学術的に困難なのかを究明する。
- **情報損失の分析**: 表面構文（Surface Syntax）から内部表現（Expr/Kernel）への変換過程における情報の欠落を観測・分類する。
- **安全なプログラム変換**: 再エラボレーション（Re-elaboration）ループを用いた、意味保存を保証するフレームワークの構築。
- **局所フォーマット（Scoped Formatting）**: 複雑な証明への影響を最小限に抑える局所的な整形戦略の実装。

---

## 🏗️ 主要コンポーネント

- **`#analyze_term` コマンド**: 項が Surface Syntax、Elaboration、Delaboration の各段階でどのように変換されるかを可視化するカスタムメタコマンド。
- **意味保存の検証ループ**: `Elab(Format(S)) ≡ Elab(S)` であることを機械的に保証する検証機構。
- **段階注釈付き層別化モデル**: 表面、マクロ、意味の各情報を適切に扱うための構造的モデル。

---

## 🏗️ プロジェクト構成

```text
lean-formatter-lab/
├── LeanFormatterLab/          # プロジェクトソースルート (PascalCase)
│   ├── Analyze.lean          # メタコマンドの実装
│   ├── Lab/
│   │   ├── Issues/           # 整形エラーの具体例
│   │   ├── Experiments/      # Notationやマクロの実験
│   │   └── ReElabTests.lean  # 意味保存プロトタイプ
│   └── Theory/               # 理論的定式化
├── LeanFormatterLab.lean      # ライブラリエントリポイント
└── lakefile.lean
```

---

## 📄 ライセンス

本プロジェクトは MIT ライセンスの下で公開されています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

---

## ⚠️ AI 学習および利用に関する制限

本リポジトリのコンテンツは教育および研究目的で提供されています。
事前の書面による明示的な同意なく、本リポジトリの内容を機械学習モデル（LLMを含む）のトレーニングに使用することは禁止されています。

---

## ⚙️ 環境構築

```bash
lake update
lake build
```
