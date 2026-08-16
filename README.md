<h1 align="center">🪨 Caveman Ultra for Claude Code</h1>

<p align="center">
  <b>Make <a href="https://claude.com/claude-code">Claude Code</a> talk like a smart caveman ~75% fewer output tokens, 100% technical accuracy.</b><br>
  Auto-enabled on every new chat. Ships a slick statusline showing mode, model, and current folder.
</p>

<p align="center">
  <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="Claude Code" src="https://img.shields.io/badge/for-Claude%20Code-8A2BE2">
  <img alt="Shell" src="https://img.shields.io/badge/shell-bash-121011">
  <img alt="PRs welcome" src="https://img.shields.io/badge/PRs-welcome-brightgreen">
</p>

<img src="docs/statusline-v2.png" alt="Caveman Ultra statusline" width="100%">

## Why

Claude's default prose is verbose: articles, hedging, "I'd be happy to help", decorative filler. All of it costs output tokens and slows you down. **Caveman mode strips the fluff and keeps the substance** — file names, commands, code, error strings and paths stay byte-exact. Only the prose gets compressed.

Typical result: **~65–75% fewer output tokens** per reply, faster answers, lower cost, same correctness.

```
Normal:  "Your component re-renders because you create a new object reference
          each render. Wrapping it in useMemo will fix the issue."

Caveman: "Inline obj prop → new ref → re-render. useMemo."
```

## Features

- 🧠 **Auto-enabled** — every new Claude Code chat starts in caveman ultra, no command needed.
- 🎚️ **6 intensity levels** — `lite`, `full`, `ultra`, plus classical-Chinese `wenyan-{lite,full,ultra}`.
- 📊 **Statusline** — `🪨 CAVEMAN ULTRA | <model> | <current folder>` under your prompt.
- 🌍 **Language-preserving** — replies stay in whatever language you write; only the style compresses.
- 🔒 **Accuracy-safe** — auto-drops to normal prose for security warnings and destructive-action confirmations.
- 🧩 **Non-destructive install** — merges into your existing config, fully reversible.
- 📦 **Zero dependencies** — pure `bash`, nothing to install first.

## What's inside

| File | Role |
|------|------|
| `skills/caveman/` | The `caveman` skill — the compression engine (6 levels). |
| `statusline-caveman.sh` | Statusline script (reads model + folder from the session JSON, pure bash). |
| `caveman-ultra.md` | Block injected into your `~/.claude/CLAUDE.md` that forces auto-activation. |
| `install.sh` / `uninstall.sh` | Idempotent, non-destructive install / removal. |

## Requirements

- [Claude Code](https://claude.com/claude-code)
- `bash` 3.2+ — works on macOS, Linux, WSL and Git Bash on Windows

That's it. No `jq`, no runtime, nothing to install first. The statusline parses the
session JSON in pure bash, and the installer edits `settings.json` with whichever of
`node` / `python3` / `jq` your machine already has — if it has none, it tells you the
one line to paste and installs everything else anyway.

## Install

```bash
git clone https://github.com/Gildaciolopes/claude-caveman-ultra.git
cd claude-caveman-ultra
./install.sh
```

Restart Claude Code. Every new chat now opens in caveman ultra and the statusline appears.

The installer is **idempotent** and **non-destructive**:
- copies the skill to `~/.claude/skills/caveman`
- copies the statusline script and enables `statusLine` in `~/.claude/settings.json` (preserving every other key)
- injects the activation block into `~/.claude/CLAUDE.md` between
  `<!-- BEGIN CAVEMAN ULTRA -->` / `<!-- END CAVEMAN ULTRA -->` markers (re-running only replaces the block, never duplicates)

## Use on another machine

Same `git clone` + `./install.sh` on any machine that has Claude Code.

## Control the level during a session

```
/caveman lite      # light compression
/caveman full      # default
/caveman ultra     # maximum compression (this package's default)
stop caveman       # back to normal prose for this session
```

### Intensity levels

| Level | What changes |
|-------|--------------|
| `lite` | Drop filler/hedging. Full sentences. Professional but tight. |
| `full` | Drop articles, fragments OK, short synonyms. Classic caveman. |
| `ultra` | Bare fragments, abbreviations (DB, auth, fn), arrows for causality. |
| `wenyan-lite` | Classical Chinese register, light compression. |
| `wenyan-full` | Maximum 文言文, 80–90% character reduction. |
| `wenyan-ultra` | Extreme classical compression. |

## Uninstall

```bash
./uninstall.sh
```

Removes the skill, the script and the `statusLine` line, and deletes only the marked
block from your `CLAUDE.md`. The rest of your config stays intact.

## Contributing

Issues and PRs welcome. If it saves you tokens, a ⭐ helps others find it.

## License

[MIT](LICENSE).
