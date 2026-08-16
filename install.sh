#!/usr/bin/env bash
# Installs CAVEMAN ULTRA for Claude Code:
#   1. skill  caveman  -> ~/.claude/skills/caveman
#   2. statusline       -> ~/.claude/statusline-caveman.sh + settings.json
#   3. auto-activation  -> block injected into ~/.claude/CLAUDE.md
# Idempotent: running it again does not duplicate anything.
# No hard dependencies: edits settings.json with whichever of node/python3/jq
# is present, and falls back to writing the file directly when it is new.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN="<!-- BEGIN CAVEMAN ULTRA -->"
END="<!-- END CAVEMAN ULTRA -->"
STATUSLINE_CMD="~/.claude/statusline-caveman.sh"

mkdir -p "$CLAUDE_DIR/skills"

# 1. skill
echo "==> caveman skill"
rm -rf "$CLAUDE_DIR/skills/caveman"
cp -r "$REPO_DIR/skills/caveman" "$CLAUDE_DIR/skills/caveman"

# 2. statusline script + settings.json
echo "==> statusline"
cp "$REPO_DIR/statusline-caveman.sh" "$CLAUDE_DIR/statusline-caveman.sh"
chmod +x "$CLAUDE_DIR/statusline-caveman.sh"

# Merge .statusLine into settings.json, preserving every other key.
set_statusline() {
  if [ ! -s "$SETTINGS" ] || [ "$(tr -d '[:space:]' < "$SETTINGS")" = "{}" ]; then
    printf '{\n  "statusLine": {\n    "type": "command",\n    "command": "%s"\n  }\n}\n' \
      "$STATUSLINE_CMD" > "$SETTINGS"
    return 0
  fi

  if command -v node >/dev/null 2>&1; then
    node -e '
      const fs = require("fs"), [p, cmd] = process.argv.slice(1);
      const s = JSON.parse(fs.readFileSync(p, "utf8"));
      s.statusLine = { type: "command", command: cmd };
      fs.writeFileSync(p, JSON.stringify(s, null, 2) + "\n");
    ' "$SETTINGS" "$STATUSLINE_CMD"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c '
import json, sys
p, cmd = sys.argv[1], sys.argv[2]
with open(p) as f:
    s = json.load(f)
s["statusLine"] = {"type": "command", "command": cmd}
with open(p, "w") as f:
    json.dump(s, f, indent=2)
    f.write("\n")
' "$SETTINGS" "$STATUSLINE_CMD"
  elif command -v jq >/dev/null 2>&1; then
    tmp="$(mktemp)"
    jq --arg cmd "$STATUSLINE_CMD" \
       '.statusLine = {"type":"command","command":$cmd}' "$SETTINGS" > "$tmp" \
       && mv "$tmp" "$SETTINGS"
  else
    return 1
  fi
}

if ! set_statusline; then
  cat <<EOF

warning: could not edit $SETTINGS automatically
         (needs one of: node, python3, jq).
         The skill and auto-activation are installed. To get the statusline,
         add this key to $SETTINGS by hand:

  "statusLine": { "type": "command", "command": "$STATUSLINE_CMD" }

EOF
fi

# 3. auto-activation block in CLAUDE.md (between markers, replaceable)
echo "==> auto-activation in CLAUDE.md"
touch "$CLAUDE_MD"
if grep -qF "$BEGIN" "$CLAUDE_MD"; then
  # remove the old block
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
echo "Done. Restart Claude Code. The statusline shows 🪨 CAVEMAN ULTRA."
