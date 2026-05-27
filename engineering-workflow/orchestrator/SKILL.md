---
name: orchestrator
description: Pipeline coordinator for multi-stage agentic ticket workflows. Owns task-isolated state, dispatches agents, evaluates gates, coordinates parallel execution, and routes between stages. Supports multiple parallel tasks through branch-affinity and isolated state storage. Load this skill when running a full ticket pipeline.
---

# Orchestrator

The orchestrator runs the pipeline. It owns task-isolated state, dispatches agents,
evaluates gates, and routes the pipeline based on gate results.

## References

- [references/state.md](references/state.md) — task-isolated state schema and branch affinity
- [references/dispatch.md](references/dispatch.md) — agent dispatch and scoped payloads
- [references/parallel.md](references/parallel.md) — parallel execution and merge logic
- [references/recovery.md](references/recovery.md) — loop-back and human gate handling

---

## Task Management

All commands must target a specific `task_id`. The orchestrator ensures environment
isolation by switching to the correct git branch for each task.

**Active Task Selection:**
- `orchestrator start <task_id>`: Initialize a new task and branch.
- `orchestrator switch <task_id>`: Switch context and branch to an existing task.
- `orchestrator status`: List all active tasks and their current pipeline stage.

---

## Pipeline lifecycle

```
1. Pre-flight        → verify task/branch, load gates, initialize/load state
2. Extract           → dispatch Extractor, evaluate GATE-S2
3. Analyze           → dispatch Analyzer, evaluate GATE-W2
4. Parallel branch   → dispatch Challenger + Risk Assessment concurrently
5. Merge             → merge parallel outputs, evaluate GATE-S3
6. Plan              → dispatch Planner, evaluate GATE-W3
7. Validate          → dispatch Validator, evaluate GATE-W4 + GATE-S4
8. Deliver           → dispatch delivery steps after GATE-S4 passes
```

---

## Orchestrator responsibilities

**Always the orchestrator's job:**
- Managing task-isolated state files in `.ai/tasks/`.
- **Branch Enforcement**: Ensuring the current branch matches the task before modification.
- Building agent payloads and evaluating gates.
- Routing: proceed, loop-back, human pause, or fail.
- Recording pipeline history.

---

## Hard rules

- **No task_id, no action.** Every request must be tied to a specific task.
- **Branch matches Task.** Implementation stages (Plan/Execute/Deliver) are blocked if
  the git branch is incorrect.
- **One gate evaluation per stage transition.** No exceptions.
- **Shared state is append-only.** Historical outputs are preserved for traceability.
- **Human gates pause everything.** Proceed only after explicit user resolution.
- **Loop limit is 2 retries (3 total attempts).** Third failure escalates to human.
