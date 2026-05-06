# Lean Formatter Lab

[![Lean](https://img.shields.io/badge/Lean-4-blue)](https://leanprover.github.io/)
[![Status](https://img.shields.io/badge/status-in_progress-yellow)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

🇯🇵 Japanese Version → [README.ja.md](README.ja.md)

This repository is an experimental environment for research and development of a **Semantic-preserving Code Formatter** for Lean 4. 

The project focuses on bridging the gap created by **multi-stage computation**, where information such as comments, whitespace, and specific notations are often lost during the elaboration process.

---

## 🎯 Purpose

- **Researching the "Theory Wall"**: Investigating why building a robust formatter for Lean 4 is academically challenging compared to conventional languages.
- **Information Loss Analysis**: Observing and categorizing how source-level information (Surface Syntax) is transformed or lost when moving to internal representations (Expr/Kernel).
- **Safe Program Transformation**: Developing a formal framework for "meaning-preserving" transformations using a re-elaboration feedback loop.
- **Scoped Formatting**: Implementing localized formatting strategies that minimize side effects on complex proofs.

---

## 🏗️ Key Components

- **`#analyze_term` Command**: A custom meta-command to visualize the transformation of a term through Surface Syntax, Elaboration, and Delaboration phases.
- **Re-elaboration Loop**: A verification mechanism ensuring that `Elab(Format(S)) ≡ Elab(S)`.
- **Stage-Annotated Layers**: A structural model to handle different information levels (Surface, Macro, Semantic).

---

## 🏗️ Project Structure

```text
lean-formatter-lab/
├── LeanFormatterLab/          # Project source root (PascalCase)
│   ├── Analyze.lean          # Meta-command implementation
│   ├── Lab/
│   │   ├── Issues/           # Test cases for formatting failures
│   │   ├── Experiments/      # Notation/Macro experiments
│   │   └── ReElabTests.lean  # Meaning-preserving prototypes
│   └── Theory/               # Theoretical formalizations
├── LeanFormatterLab.lean      # Library entry point
└── lakefile.lean
```

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## ⚠️ AI Training and Usage Restriction

The contents of this repository are provided for educational and research purposes.
Use of this repository for training machine learning models (including LLMs) is not permitted without explicit prior written consent.

---

## ⚙️ Environment Setup

```bash
lake update
lake build
```
