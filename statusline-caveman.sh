#!/usr/bin/env bash
# Statusline: flag permanente de CAVEMAN ULTRA + contexto da sessão.
input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')
dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir="${dir##*/}"

printf '\033[1;33m🪨 CAVEMAN ULTRA\033[0m  \033[2m|\033[0m  %s  \033[2m|\033[0m  \033[36m%s\033[0m' "$model" "$dir"
