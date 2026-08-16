#!/usr/bin/env bash
# Removes CAVEMAN ULTRA. Does not wipe your CLAUDE.md — only the marked block.
set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="<!-- BEGIN CAVEMAN ULTRA -->"
END="<!-- END CAVEMAN ULTRA -->"

rm -rf "$CLAUDE_DIR/skills/caveman"
rm -f  "$CLAUDE_DIR/statusline-caveman.sh"

# Drop .statusLine with whichever JSON tool is available, keeping the rest.
del_statusline() {
  if command -v node >/dev/null 2>&1; then
    node -e '
      const fs = require("fs"), p = process.argv[1];
      const s = JSON.parse(fs.readFileSync(p, "utf8"));
      delete s.statusLine;
      fs.writeFileSync(p, JSON.stringify(s, null, 2) + "\n");
    ' "$SETTINGS"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import json, sys
p = sys.argv[1]
with open(p) as f:
    s = json.load(f)
s.pop("statusLine", None)
with open(p, "w") as f:
    json.dump(s, f, indent=2)
    f.write("\n")
' "$SETTINGS"
  elif command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq 'del(.statusLine)' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  else
    return 1
  fi
}

if [ -s "$SETTINGS" ] && ! del_statusline; then
  echo "warning: could not edit $SETTINGS (needs node, python3 or jq)."
  echo "         Remove the \"statusLine\" key by hand."
fi

if [ -f "$CLAUDE_MD" ] && grep -qF "$BEGIN" "$CLAUDE_MD"; then
  awk -v b="$BEGIN" -v e="$END" '
    $0==b{skip=1} !skip{print} $0==e{skip=0}' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
fi

echo "Removed. Restart Claude Code."
