# ai-skills

Portable AI Agent configuration. Skills are grouped by **flow** — the sequence of steps a user performs — not by technical domain.

## Structure

| Path | Purpose |
|---|---|
| `engineering-workflow/` | Ticket pipeline: setup → orchestrator → gates → agents → verify |
| `planning/` | Initiative-to-ticket planning → Jira creation |
| `job-posting-extractor/` | Scrape job boards and career pages → structured JSON |
| `AGENTS.md` | Cross-project rules, conventions, design principles |

## Setup on a new machine

```bash
git clone <this-repo> ~/ai-skills
cd ~/ai-skills
ln -sf "$PWD"/AGENTS.md ~/.claude/CLAUDE.md
ln -sf "$PWD"/AGENTS.md ~/.gemini/GEMINI.md
```

## Adding a new flow

1. Create `{flow-name}/` at the project root.
2. Add skill directories inside it, each with a `SKILL.md`.
3. Add a `references/` directory for shared schemas or patterns.
4. Update this table.

## Per-project setup

Each repo gets its own `AGENTS.md` with stack, dev commands, `/verify` definition, and architecture overview.
