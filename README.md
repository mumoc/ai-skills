# ai-skills

Portable AI Agent configuration. Clone once, bootstrap any machine in one command.
Provides global rules, permissions, MCP servers, and a full agentic skill suite.

## Bootstrap a new machine

```bash
git clone <this-repo> ~/Projects/ai-skills
cd ~/Projects/ai-skills
./scripts/bootstrap.sh
```

This will:

- Symlink `global/AGENTS.md` → `~/.ai-skills/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.gemini/GEMINI.md`
- Symlink `global/claude/settings.json` → `~/.claude/settings.json` and `~/.ai-skills/settings.json`
- Copy all skills from `skills/` into `~/.ai-skills/skills/`

A single `AGENTS.md` source is symlinked to each tool's expected location so Claude Code, Gemini CLI, and OpenAI Codex all read the same global rules.

Existing files are backed up before being replaced (`.bak` suffix).

## Stay up to date

```bash
./scripts/update.sh
```

Pulls the latest changes and re-runs the bootstrap.

---

## What's tracked

| Path | Purpose |
|---|---|
| `global/AGENTS.md` | Global rules, conventions, and all skill registrations (tool-agnostic) |
| `global/claude/settings.json` | Claude Code: allowed bash commands, hooks, MCP server config |
| `skills/` | All skills installed into `~/.ai-skills/skills/` |
| `templates/AGENTS.md` | Starter template for per-project `AGENTS.md` files |
| `docs/` | MCP setup and other operational guides |

---

## Skill suite

### Infrastructure skills

These coordinate the pipeline. Only the orchestrator loads gates. Individual agents
never load either directly.

| Skill | Purpose |
|---|---|
| `gates` | Gate types, conditions, routing logic, and stage contracts |
| `orchestrator` | Task-isolated coordinator — shared state, branch affinity, recovery |
| `setup` | Repo scanner — produces grounding documents consumed by all agents |

### Workflow skills

| Skill | Purpose |
|---|---|
| `engineering-workflow` | Task-isolated lifecycle: analyze → plan → TDD → review → PR |
| `jira-ticket-planning` | Initiative-to-ticket planning, classification, sprint placement |
| `verify` | Lint + test gate. Work is never done until this passes clean |

### Pipeline agents

Dispatched exclusively by the orchestrator. Each agent does one job.

| Agent | Role |
|---|---|
| `agents/extractor` | Structures raw ticket into a typed object |
| `agents/analyzer` | Interprets intent, maps to domain rules, scores confidence |
| `agents/challenger` | Adversarial business/product review — finds what is wrong |
| `agents/risk-assessment` | Technical risk review — runs in parallel with challenger |
| `agents/planner` | Produces TDD-ordered implementation plan with full traceability |
| `agents/security` | Adversarial security review of implementation diff |
| `agents/reviewer` | Quality and architectural consistency review |
| `agents/validator` | Verifies implementation against ticket before delivery |

---

## How the agentic pipeline works

### Setup phase (run once per repo)

```
Repository
  │
  ├── namespace READMEs ──┐
  ├── YARD / JSDoc        ├──► [Setup Skill] ──► context/
  ├── schema files        │                        ├── domain_glossary.md
  └── AI.md ──────────┘                        ├── {service}_context.md
                                                   └── .setup_manifest.json
```

The setup skill harvests business rules and domain knowledge from existing
documentation. It asks targeted questions only for gaps harvest cannot fill.
All agents read from `context/` — setup is what makes them accurate.

The manifest stores a structural hash of the repo. Agents check it before running.
If the hash drifts (new models, new services), setup re-runs the affected sections.

---

### Ticket pipeline (per ticket)

```
Raw ticket
    │
    ▼
[Extractor] ──GATE-S2──► structured ticket object
    │
    ▼
[Analyzer] ──GATE-W2──► intent + criteria + gaps + confidence
    │
    ├──────────────────────────────┐
    ▼                              ▼
[Challenger]              [Risk Assessment]
business/product lens     technical lens
    │                              │
    └──────────── merge ───────────┘
                   │
               GATE-S3 ──► human gate if critical issues unresolved
                   │
                   ▼ (plan approved)
              [Planner] ──GATE-W3──► ordered task list, TDD-first
                   │
                   ▼ (implementation)
             [Reviewer]          [Security]
             quality lens        security lens
                   │                   │
                   └─────── merge ─────┘
                             │
                         GATE-S3.5/7 ──► loop-back if strict violations
                             │
                             ▼
                        [Validator] ──GATE-W4──► coverage + contradiction + doc delta
                             │
                         GATE-S4 ──► delivery approval
                             │
                             ▼
                        [Deliver] ──► push + PR
```

---

### Gate types

```
STRICT ──► hard stop. Pipeline cannot continue.
           Used for: setup check, ticket minimum, plan approval, delivery approval.

SOFT ───► pipeline continues with warning attached to payload.
           Used for: analysis confidence, partial coverage, doc gaps.

HUMAN ──► pipeline pauses. One specific question surfaces to the user.
           Used for: ambiguous ticket, critical issues, accumulated warnings,
           validation contradictions.
```

---

### Shared state (orchestrator-owned)

```json
{
  "task_id": "JIRA-123",
  "git_branch": "feature/JIRA-123",
  "status": "running | paused | failed | complete",
  "stages": {                    ← append-only.
    "extract":  { output, attempts },
    "analyze":  { output, attempts },
    "challenge": { output, attempts },
    "risk_assessment": { output, attempts },
    "merge":    { output },
    "plan":     { output, attempts },
    "execute":  { output, attempts },
    "reviewer": { output, attempts },
    "security": { output, attempts },
    "validate": { output, attempts }
  },
  "gates": {
    "history": [...],          ← every gate evaluation recorded
    "active_warnings": [...],  ← accumulate until resolved
    "human_pauses": [...]      ← every human decision recorded
  },
  "approvals": {
    "plan_approved": bool,
    "delivery_approved": bool
  }
}
```

State is isolated per task in `.ai/tasks/{task_id}/state.json`. It is append-only so
every attempt is preserved. Loop-backs, gate failures, and human resolutions are
all traceable. No point-in-time information is lost.

### Task Management

The orchestrator enforces environment isolation by switching to the correct git branch
for each task. Every command must target a specific `task_id`.

- `orchestrator start <task_id>`: Initialize a new task and branch.
- `orchestrator switch <task_id>`: Switch context and branch to an existing task.
- `orchestrator status`: List all active tasks and their current pipeline stage.

---

### Agent isolation

```
                    [Orchestrator]
                    owns full state
                   /              \
        [Agent A]                [Agent B]
        receives                 receives
        scoped slice             scoped slice
        of state                 of state
              \                  /
               writes output ──►merge back to state
```

Agents never see the full state object. The orchestrator builds a minimum payload
per agent from state, dispatches, receives output, and writes it back.
Parallel agents receive the same snapshot — neither sees the other's in-progress output.

---

### Loop-back and recovery

```
Stage output
    │
    ▼
Gate evaluates
    │
    ├── proceed ──────────────────► next stage
    │
    ├── proceed-with-warnings ────► next stage + warning in payload
    │
    ├── loop-back (attempt ≤ 2) ──► re-dispatch with targeted instruction
    │
    ├── loop-back (attempt = 3) ──► escalate to human gate
    │
    ├── human ────────────────────► pause, surface one question, resume
    │
    └── fail ─────────────────────► stop, preserve state, report
```

Loop limit is 2 retries (3 total attempts) per stage. On the third failure the
orchestrator escalates rather than retrying — preventing infinite loops while
preserving the full attempt history in state.

---

## Adding a new skill

1. Create `skills/<skill-name>/SKILL.md` with frontmatter and instructions.
2. Add references in `skills/<skill-name>/references/` if needed.
3. Register it in `global/AI.md` under `## Skills`.
4. Run `./scripts/bootstrap.sh` to install.

For agent skills, place under `skills/agents/<agent-name>/SKILL.md` and register
in the agents table in `global/AI.md`.

---

## MCP authentication

After bootstrapping, some servers need a one-time login per machine.
See [`docs/mcp-setup.md`](docs/mcp-setup.md) for details.

**GitHub** — set in your shell profile:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN=...
```

**Atlassian** — OAuth browser login on first use, no env var needed.

---

## Per-project setup

Each repo gets its own `AGENTS.md`. Use `templates/AGENTS.md` as the starting point.

Required fields:
- Stack and local port
- Dev / test / lint commands
- `/verify` definition (lint + test commands)
- Architecture overview
- Performance-sensitive areas

To support all tools from a single file, optionally add symlinks in the project root:

```bash
ln -s AGENTS.md CLAUDE.md   # Claude Code
ln -s AGENTS.md GEMINI.md   # Gemini CLI
# OpenAI Codex reads AGENTS.md directly — no symlink needed
```

**Making skills available to Codex** — Codex doesn't expand `~` when following file paths,
so skills must be reachable via a project-relative path. Run once per repo:

```bash
~/Projects/ai-skills/scripts/link-skills.sh
```

This creates `.agents/skills/ → ~/.ai-skills/skills/` and adds `.agents/` to `.gitignore`.
Reference skills in `AGENTS.md` as `.agents/skills/<name>/SKILL.md`.

For agentic workflows, run the `setup` skill first to generate `context/` grounding
documents. Engineering-workflow will use them automatically during analysis.
