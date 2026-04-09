#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

printf 'Bootstrapping Claude config from %s\n\n' "$REPO_ROOT"

# --- Global CLAUDE.md ---
if [[ -e "$CLAUDE_HOME/CLAUDE.md" && ! -L "$CLAUDE_HOME/CLAUDE.md" ]]; then
  printf 'Backing up existing CLAUDE.md → %s/CLAUDE.md.bak\n' "$CLAUDE_HOME"
  mv "$CLAUDE_HOME/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md.bak"
fi
ln -sf "$REPO_ROOT/global/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
printf '✓ Linked CLAUDE.md\n'

# --- settings.json ---
if [[ -e "$CLAUDE_HOME/settings.json" && ! -L "$CLAUDE_HOME/settings.json" ]]; then
  printf 'Backing up existing settings.json → %s/settings.json.bak\n' "$CLAUDE_HOME"
  mv "$CLAUDE_HOME/settings.json" "$CLAUDE_HOME/settings.json.bak"
fi
ln -sf "$REPO_ROOT/global/settings.json" "$CLAUDE_HOME/settings.json"
printf '✓ Linked settings.json\n'

# --- Skills ---
# Copies all skills recursively, including nested agent skills under skills/agents/.
# Existing skill directories are replaced cleanly on each run.
mkdir -p "$CLAUDE_HOME/skills"

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
install_skills "$REPO_ROOT/skills" "$CLAUDE_HOME/skills"

# --- Cleanup stale .bak files in global/ ---
# These are created as temp artifacts during repo editing. Safe to remove.
find "$REPO_ROOT/global" -name "*.bak" -delete 2>/dev/null && \
  printf '\n✓ Cleaned up stale .bak files\n' || true

printf '\nBootstrap complete.\n'
printf 'Claude home: %s\n' "$CLAUDE_HOME"
printf '\nNext steps:\n'
printf '  1. Verify MCP auth — see docs/mcp-setup.md\n'
printf '  2. On each repo: add CLAUDE.md from templates/CLAUDE.md\n'
printf '  3. Before first agentic workflow on a repo: run the setup skill\n'
