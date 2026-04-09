#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SKILLS_HOME="${AI_SKILLS_HOME:-$HOME/.ai-skills}"

printf 'Bootstrapping the Agent config from %s\n\n' "$REPO_ROOT"

mkdir -p "$AI_SKILLS_HOME"

# ---------------------------------------------------------------------------
# Helper: symlink a source file to a destination, backing up any non-symlink
# ---------------------------------------------------------------------------
install_symlink() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    printf 'Backing up existing %s → %s.bak\n' "$dest" "$dest"
    mv "$dest" "$dest.bak"
  fi
  ln -sf "$src" "$dest"
}

# ---------------------------------------------------------------------------
# AGENTS.md — universal agent instructions
# Symlinked to each tool's expected location so all tools see the same rules.
# ---------------------------------------------------------------------------
install_symlink "$REPO_ROOT/global/AGENTS.md" "$AI_SKILLS_HOME/AGENTS.md"
printf '✓ Linked AGENTS.md → ~/.ai-skills/AGENTS.md\n'

# Claude Code reads ~/.claude/CLAUDE.md as the global agent instructions file.
# If a real CLAUDE.md already exists (e.g. a personal or team context file), we
# prepend an @import so both files stay in effect rather than replacing it.
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
IMPORT_LINE="@${REPO_ROOT}/global/AGENTS.md"
if [[ -L "$CLAUDE_MD" ]]; then
  # It's already a symlink — replace it
  install_symlink "$REPO_ROOT/global/AGENTS.md" "$CLAUDE_MD"
  printf '✓ Linked AGENTS.md → ~/.claude/CLAUDE.md\n'
elif [[ -f "$CLAUDE_MD" ]]; then
  # Real file exists — add import at the top if not already present
  if grep -qF "$IMPORT_LINE" "$CLAUDE_MD" 2>/dev/null; then
    printf '✓ ~/.claude/CLAUDE.md already imports AGENTS.md\n'
  else
    printf '%s\n\n%s' "$IMPORT_LINE" "$(cat "$CLAUDE_MD")" > "$CLAUDE_MD"
    printf '✓ Prepended @import of AGENTS.md to ~/.claude/CLAUDE.md\n'
  fi
else
  # No file yet — create symlink
  install_symlink "$REPO_ROOT/global/AGENTS.md" "$CLAUDE_MD"
  printf '✓ Linked AGENTS.md → ~/.claude/CLAUDE.md\n'
fi

# Gemini CLI reads ~/.gemini/GEMINI.md as the global agent instructions file
install_symlink "$REPO_ROOT/global/AGENTS.md" "$HOME/.gemini/GEMINI.md"
printf '✓ Linked AGENTS.md → ~/.gemini/GEMINI.md\n'

# ---------------------------------------------------------------------------
# Claude Code settings (permissions, hooks, MCP servers)
# ---------------------------------------------------------------------------
install_symlink "$REPO_ROOT/global/claude/settings.json" "$HOME/.claude/settings.json"
printf '✓ Linked claude/settings.json → ~/.claude/settings.json\n'

# Keep a copy at the legacy location for tools that may reference it
install_symlink "$REPO_ROOT/global/claude/settings.json" "$AI_SKILLS_HOME/settings.json"
printf '✓ Linked claude/settings.json → ~/.ai-skills/settings.json\n'

# ---------------------------------------------------------------------------
# Skills — installed to ~/.ai-skills/skills/
# Each skill directory is replaced cleanly on every run.
# ---------------------------------------------------------------------------
mkdir -p "$AI_SKILLS_HOME/skills"

install_skills() {
  local source_dir="$1"
  local dest_dir="$2"

  for entry in "$source_dir"/*/; do
    [[ -d "$entry" ]] || continue
    local name
    name="$(basename "$entry")"

    # If this directory contains a SKILL.md it is a leaf skill — install it.
    # If not, it is a namespace directory (e.g. agents/) — recurse into it.
    if [[ -f "$entry/SKILL.md" ]]; then
      mkdir -p "$dest_dir"
      rm -rf "$dest_dir/$name"
      cp -R "$entry" "$dest_dir/$name"
      printf '  ✓ Installed skill: %s\n' "$name"
    else
      printf '  → Entering namespace: %s\n' "$name"
      mkdir -p "$dest_dir/$name"
      install_skills "$entry" "$dest_dir/$name"
    fi
  done
}

printf '\nInstalling skills:\n'
install_skills "$REPO_ROOT/skills" "$AI_SKILLS_HOME/skills"

# ---------------------------------------------------------------------------
# Cleanup stale .bak files in global/ — temp artifacts from repo editing
# ---------------------------------------------------------------------------
find "$REPO_ROOT/global" -name "*.bak" -delete 2>/dev/null && \
  printf '\n✓ Cleaned up stale .bak files\n' || true

printf '\nBootstrap complete.\n'
printf 'AI Skills home: %s\n' "$AI_SKILLS_HOME"
printf '\nInstalled:\n'
printf '  AGENTS.md → ~/.ai-skills/AGENTS.md\n'
printf '  AGENTS.md → ~/.claude/CLAUDE.md  (Claude Code)\n'
printf '  AGENTS.md → ~/.gemini/GEMINI.md  (Gemini CLI)\n'
printf '  settings  → ~/.claude/settings.json\n'
printf '\nNext steps:\n'
printf '  1. Verify MCP auth — see docs/mcp-setup.md\n'
printf '  2. On each repo: add AGENTS.md from templates/AGENTS.md\n'
printf '     Optionally symlink CLAUDE.md → AGENTS.md and GEMINI.md → AGENTS.md\n'
printf '  3. Before first agentic workflow on a repo: run the setup skill\n'
