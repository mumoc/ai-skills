# ai-skills

Portable AI Agent configuration. Skills are grouped by **flow** — the sequence of steps a user performs — not by technical domain.

## Structure

| Path | Purpose |
|---|---|
| `engineering-workflow/` | Ticket pipeline: setup → orchestrator → gates → agents → verify |
| `planning/` | Initiative-to-ticket planning → Jira creation |
| `AGENTS.md` | Cross-project rules, conventions, design principles |
| `SKILL.md` | Root entry-point coordinator |
| `agents.json` | Agent registry for tool discovery |
| `tile.json` | Canonical skill/agent inventory |
| `CLAUDE.md` | Symlink → `AGENTS.md` (Claude Code) |
| `GEMINI.md` | Symlink → `AGENTS.md` (Gemini CLI) |

## Setup on a new machine

```bash
git clone <this-repo> ~/ai-skills
cd ~/ai-skills
ln -sf "$PWD"/AGENTS.md ~/.claude/CLAUDE.md
ln -sf "$PWD"/AGENTS.md ~/.gemini/GEMINI.md
```

## Adding a new skill

1. Identify which **flow** it belongs to (or create a new flow directory).
2. Create `{flow}/{skill-name}/SKILL.md` with frontmatter and instructions.
3. Add `references/` files if needed.
4. Register in `tile.json` under the appropriate flow.

## Per-project setup

Each repo gets its own `AGENTS.md` with stack, dev commands, `/verify` definition, and architecture overview.
