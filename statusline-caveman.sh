#!/usr/bin/env bash
# Statusline: permanent CAVEMAN ULTRA flag + session context.
# No external dependencies: parses the two fields it needs in pure bash,
# which also avoids spawning a process on every render.
input=$(cat)

# Flatten to a single line so the regexes below work on pretty-printed JSON too.
flat=${input//$'\n'/ }

json_str() { # $1 = key name -> echoes the string value, or empty
  local re="\"$1\"[[:space:]]*:[[:space:]]*\"((\\\\.|[^\"\\\\])*)\""
  [[ $flat =~ $re ]] || return 1
  local v=${BASH_REMATCH[1]}
  v=${v//\\\//\/}
  v=${v//\\\"/\"}
  printf '%s' "$v"
}

model=$(json_str display_name) || model="?"
[ -n "$model" ] || model="?"

dir=$(json_str current_dir) || dir=$(json_str cwd) || dir=""
dir="${dir##*/}"

printf '\033[1;33m🪨 CAVEMAN ULTRA\033[0m  \033[2m|\033[0m  %s  \033[2m|\033[0m  \033[36m%s\033[0m' "$model" "$dir"
