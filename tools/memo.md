mkdir -p tools

REF=$(cat lean-toolchain)
REF=${REF#leanprover/lean4:}

echo "Using Lean ref: $REF"

curl -L \
"https://raw.githubusercontent.com/leanprover/lean4/${REF}/script/reformat.lean" \
-o tools/reformat.lean

をコンパイルエラーを微修正