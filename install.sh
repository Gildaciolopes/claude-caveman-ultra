#!/usr/bin/env bash
# Instala o CAVEMAN ULTRA para Claude Code:
#   1. skill  caveman  -> ~/.claude/skills/caveman
#   2. statusline       -> ~/.claude/statusline-caveman.sh + settings.json
#   3. auto-ativação    -> bloco injetado em ~/.claude/CLAUDE.md
# Idempotente: rodar de novo não duplica nada.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="<!-- BEGIN CAVEMAN ULTRA -->"
END="<!-- END CAVEMAN ULTRA -->"

command -v jq >/dev/null || { echo "erro: precisa de 'jq' instalado"; exit 1; }

mkdir -p "$CLAUDE_DIR/skills"

# 1. skill
echo "==> skill caveman"
rm -rf "$CLAUDE_DIR/skills/caveman"
cp -r "$REPO_DIR/skills/caveman" "$CLAUDE_DIR/skills/caveman"

# 2. statusline script + settings.json
echo "==> statusline"
cp "$REPO_DIR/statusline-caveman.sh" "$CLAUDE_DIR/statusline-caveman.sh"
chmod +x "$CLAUDE_DIR/statusline-caveman.sh"

[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
tmp="$(mktemp)"
jq '.statusLine = {"type":"command","command":"~/.claude/statusline-caveman.sh"}' \
   "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

# 3. bloco de auto-ativação no CLAUDE.md (entre marcadores, substituível)
echo "==> auto-ativação em CLAUDE.md"
touch "$CLAUDE_MD"
if grep -qF "$BEGIN" "$CLAUDE_MD"; then
  # remove bloco antigo
  awk -v b="$BEGIN" -v e="$END" '
    $0==b{skip=1} !skip{print} $0==e{skip=0}' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
fi
{
  printf '\n%s\n' "$BEGIN"
  cat "$REPO_DIR/caveman-ultra.md"
  printf '%s\n' "$END"
} >> "$CLAUDE_MD"

echo
echo "OK. Reinicie o Claude Code. Statusline mostra 🪨 CAVEMAN ULTRA."
