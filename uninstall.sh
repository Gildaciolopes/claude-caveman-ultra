#!/usr/bin/env bash
# Remove o CAVEMAN ULTRA. Não apaga sua CLAUDE.md — só o bloco marcado.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="<!-- BEGIN CAVEMAN ULTRA -->"
END="<!-- END CAVEMAN ULTRA -->"

rm -rf "$CLAUDE_DIR/skills/caveman"
rm -f  "$CLAUDE_DIR/statusline-caveman.sh"

if [ -f "$SETTINGS" ] && command -v jq >/dev/null; then
  tmp="$(mktemp)"
  jq 'del(.statusLine)' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
fi

if [ -f "$CLAUDE_MD" ] && grep -qF "$BEGIN" "$CLAUDE_MD"; then
  awk -v b="$BEGIN" -v e="$END" '
    $0==b{skip=1} !skip{print} $0==e{skip=0}' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
fi

echo "Removido. Reinicie o Claude Code."
