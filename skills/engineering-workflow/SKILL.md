---
name: engineering-workflow
description: Manages a structured, ticket-driven engineering workflow for writing, fixing, or refactoring code. Use when the user wants to work on a specific ticket, task, or issue end-to-end — including creating a feature branch, writing tests first (TDD), running code quality and security reviews, and opening a pull request. Handles natural requests like "work this ticket", "fix this bug", "implement this feature", "start on JIRA-123", or "follow the engineering workflow". Creates isolated feature branches per ticket, enforces test-driven development, runs parallel quality and security review agents, and tracks per-ticket state from start to PR delivery.
---

# Engineering Workflow

Use this skill for any task that changes code or tests. It is task-aware and requires
a `task_id` for all operations.

## Example invocations

- "Work task JIRA-123 end to end."
- "Switch to task JIRA-456 and continue implementation."
- "Show status of all active tasks."
- "Follow the task-isolated workflow for this ticket."

## References

Load these only when the relevant phase is active:

- [references/delegation.md](references/delegation.md) — multi-agent task execution
- [references/tdd.md](references/tdd.md) — TDD execution and commit patterns
- [references/completion_bar.md](references/completion_bar.md) — pre-done checklist

---

## Task Lifecycle

```
1. Initialize       → orchestrator start <task_id> (creates branch + state)
2. Analyze          → read ticket, identify ambiguities, check context/
3. Clarify          → ask questions until scope is safe to implement
4. Inspect          → find nearest existing patterns in the codebase
5. Plan             → propose smallest action path, get approval (GATE-S3)
6. Execute (TDD)    → red → commit → green → commit → refactor → commit
7. Review           → parallel Quality (GATE-S3.5) + Security (GATE-S3.7) review
8. Verify           → run /verify, confirm all checks pass
9. Validate         → final validation against acceptance criteria
10. Deliver         → push and open PR after GATE-S4 passes
```

**Hard gates at steps 1, 5, 7, and 10.**

---

## Task Isolation Rules

- **Branch Affinity**: Every task has its own branch `feature/<task_id>`. Never
  implement Task A while on Task B's branch.
- **State Isolation**: Task state is stored in `.claude/tasks/<task_id>/state.json`.
- **Atomic Commits**: Each TDD cycle (Red, Green, Refactor) must be committed to
  the task branch. This allows the Reviewer agent to verify process discipline.

### Step 1 — Initialisation

Create the feature branch, initialise the state file, and load any existing context:

```bash
git checkout -b feature/JIRA-123
mkdir -p .claude/tasks/JIRA-123
cat > .claude/tasks/JIRA-123/state.json <<'EOF'
{
  "task_id": "JIRA-123",
  "branch": "feature/JIRA-123",
  "step": 2,
  "gates": { "S3": "pending", "S3.5": "pending", "S3.7": "pending", "S4": "pending" },
  "blockers": []
}
EOF
# Load context if present: context/JIRA-123/
```

The `state.json` tracks current lifecycle step, gate outcomes, and blocking findings
so work can be resumed across sessions.

---

## Steps 2–5: Analyze → Clarify → Inspect → Plan

### Step 2 — Analyze
Produce a short summary covering:
- **Goal**: what the ticket is asking for in one sentence.
- **Ambiguities**: requirements that are unclear, contradictory, or out of scope.
- **Risk areas**: parts of the codebase likely to be affected.

### Step 3 — Clarify
For each ambiguity, produce:
- A numbered question per open item; group related questions together.
- A stated assumption for any item the user explicitly accepts without answering.

### Step 4 — Inspect
Before writing any code, produce:
- The nearest analogous module, class, or function already in the codebase.
- A note on its naming conventions, error-handling style, and test patterns.
- A `context/<task_id>/patterns.md` recording these findings for the Execute phase.

### Step 5 — Plan (GATE-S3)
Produce a numbered implementation plan covering only the changes needed to satisfy
the acceptance criteria. Each item should name the file(s) to change and the
intended change. Present the plan and wait for explicit approval before proceeding
to Execute.

---

## Execute Phase — TDD Commit Sequence

Each behaviour change follows three atomic commits on the task branch:

```
git commit -m "test(JIRA-123): red – add failing test for <behaviour>"
git commit -m "feat(JIRA-123): green – implement <behaviour> to pass tests"
git commit -m "refactor(JIRA-123): clean up <behaviour> with no behaviour change"
```

The Reviewer agent inspects commit history to verify this discipline was followed.
Squashing or combining these commits before review is a `strict` violation.

---

## Review Phase

After implementation is complete but before final validation:

1. **Reviewer Agent**: Checks for style violations, TDD discipline, and doc gaps.
   - Any `strict` violation blocks the task.
2. **Security Agent**: Checks for vulnerabilities, secrets, and unsafe patterns.
   - Any `critical` or `high` risk blocks the task.

If either blocks, the workflow loops back to **Execute** to address the findings
before re-entering the review phase.

### Step 8 — Verify

Run lint, tests, and gate checks in sequence. Use the project's own scripts if
present (e.g. `Makefile`, `package.json`, `pyproject.toml`); otherwise fall back
to the commands below and adapt as needed:

```bash
# 1. Lint
npm run lint          # JS/TS projects
ruff check .          # Python projects
golangci-lint run     # Go projects

# 2. Tests with coverage
npm test -- --coverage
pytest --tb=short --cov
go test ./...

# 3. Gate summary — print pass/fail per gate from state.json
node -e "const s=require('./.claude/tasks/${TASK_ID}/state.json'); console.table(s.gates);"
# or: python3 -c "import json,os; s=json.load(open(f'.claude/tasks/{os.environ[\"TASK_ID\"]}/state.json')); [print(k,v) for k,v in s['gates'].items()]"
```

All lint and test commands must exit 0 before the task advances to Validate.

---

## Non-negotiables

- **Task ID first.** No work begins without a `task_id`.
- **TDD first.** Add or update the relevant spec before changing behavior.
- **Minimal design.** Change only what is required to satisfy the acceptance criteria.
- **Documentation is not optional.** Update READMEs and docblocks in the same task.
- **Never skip hooks.** Enforce lint and test gates on every commit.
