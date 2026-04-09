---
name: engineering-workflow
description: Task-isolated engineering workflow for implementation, bug fix, or refactor tasks. Enforces ticket-specific state, branch affinity, TDD discipline, and multi-agent review (Quality + Security). Operates on a specific task_id to ensure environment isolation.
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
  The orchestrator loads this state automatically based on the `task_id`.
- **Atomic Commits**: Each TDD cycle (Red, Green, Refactor) must be committed to
  the task branch. This allows the Reviewer agent to verify process discipline.

---

## Review Phase

After implementation is complete but before final validation:

1. **Reviewer Agent**: Checks for style violations, TDD discipline, and doc gaps.
   - Any `strict` violation blocks the task.
2. **Security Agent**: Checks for vulnerabilities, secrets, and unsafe patterns.
   - Any `critical` or `high` risk blocks the task.

If either blocks, the workflow loops back to **Execute** to address the findings
before re-entering the review phase.

---

## Non-negotiables

- **Task ID first.** No work begins without a `task_id`.
- **TDD first.** Add or update the relevant spec before changing behavior.
- **Minimal design.** Apply YAGNI and KISS.
- **Documentation is not optional.** Update READMEs and docblocks in the same task.
- **Never skip hooks.** Enforce lint and test gates on every commit.
