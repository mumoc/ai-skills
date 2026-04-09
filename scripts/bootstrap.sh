#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_SKILLS_HOME="${AI_SKILLS_HOME:-$HOME/.ai-skills}"

printf 'Bootstrapping the Agent config from %s\n\n' "$REPO_ROOT"

# --- Global AI.md ---
if [[ -e "$AI_SKILLS_HOME/AI.md" && ! -L "$AI_SKILLS_HOME/AI.md" ]]; then
  printf 'Backing up existing AI.md → %s/AI.md.bak\n' "$AI_SKILLS_HOME"
  mv "$AI_SKILLS_HOME/AI.md" "$AI_SKILLS_HOME/AI.md.bak"
fi
ln -sf "$REPO_ROOT/global/AI.md" "$AI_SKILLS_HOME/AI.md"
printf '✓ Linked AI.md\n'

# --- settings.json ---
if [[ -e "$AI_SKILLS_HOME/settings.json" && ! -L "$AI_SKILLS_HOME/settings.json" ]]; then
  printf 'Backing up existing settings.json → %s/settings.json.bak\n' "$AI_SKILLS_HOME"
  mv "$AI_SKILLS_HOME/settings.json" "$AI_SKILLS_HOME/settings.json.bak"
fi
ln -sf "$REPO_ROOT/global/settings.json" "$AI_SKILLS_HOME/settings.json"
printf '✓ Linked settings.json\n'

# --- Skills ---
# Copies all skills recursively, including nested agent skills under skills/agents/.
# Existing skill directories are replaced cleanly on each run.
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

# --- Cleanup stale .bak files in global/ ---
# These are created as temp artifacts during repo editing. Safe to remove.
find "$REPO_ROOT/global" -name "*.bak" -delete 2>/dev/null && \
  printf '\n✓ Cleaned up stale .bak files\n' || true

printf '\nBootstrap complete.\n'
printf 'AI Skills home: %s\n' "$AI_SKILLS_HOME"
printf '\nNext steps:\n'
printf '  1. Verify MCP auth — see docs/mcp-setup.md\n'
printf '  2. On each repo: add AI.md from templates/AI.md\n'
printf '  3. Before first agentic workflow on a repo: run the setup skill\n'
