#!/usr/bin/env bash
# Usage: Run from the root of any project repo to make skills available via a
# project-local relative path (.agents/skills/). This lets Codex and other tools
# that don't expand ~ resolve skill files without needing absolute paths.
set -euo pipefail

AI_SKILLS_HOME="${AI_SKILLS_HOME:-$HOME/.ai-skills}"

if [[ ! -d "$AI_SKILLS_HOME/skills" ]]; then
  printf 'Error: %s/skills not found. Run scripts/bootstrap.sh first.\n' "$AI_SKILLS_HOME" >&2
  exit 1
fi

mkdir -p .agents
ln -sfn "$AI_SKILLS_HOME/skills" .agents/skills

# Ensure .agents/ is gitignored
if [[ -f .gitignore ]]; then
  if ! grep -qF '.agents/' .gitignore; then
    printf '\n.agents/\n' >> .gitignore
    printf '✓ Added .agents/ to .gitignore\n'
  else
    printf '✓ .agents/ already in .gitignore\n'
  fi
else
  printf '.agents/\n' > .gitignore
  printf '✓ Created .gitignore with .agents/\n'
fi

printf '✓ Linked .agents/skills → %s/skills\n' "$AI_SKILLS_HOME"
printf '\nSkills are now reachable via relative paths in AGENTS.md:\n'
printf '  .agents/skills/engineering-workflow/SKILL.md\n'
printf '  .agents/skills/verify/SKILL.md\n'
printf '  .agents/skills/orchestrator/SKILL.md\n'
printf '  ... etc\n'
