# Recovery Reference

Loaded by the `orchestrator` skill to handle failures, loops, and pipeline repair.

---

## Recovery Principles

Recovery is task-isolated. Every failure, loop-back, or human decision is recorded
within the specific task's `.ai/tasks/{task_id}/state.json`.

---

## Loop-back Recovery

### Triggering Conditions

Route to loop-back when:
- Stage output is structurally malformed.
- A strict or soft gate identifies fixable issues (e.g., style violations).
- Agent explicitly requests a retry via `status: needs_retry`.

### Loop Limit Enforcement (Task-Scoped)

Maximum is 2 retries (3 total attempts) per stage, per task.

- **Attempt 1**: Normal dispatch.
- **Attempt 2**: Loop-back with targeted `_loop_context.instruction`.
- **Attempt 3**: Final retry with more granular instruction.
- **Attempt 4**: ESCALATE to Human Gate (GATE-H*). Do not dispatch.

---

## Human Pause Recovery

### When to Pause

- Loop limit reached.
- Strict gate failure with no automatic fix.
- Branch affinity conflict (e.g., current branch is not `feature/{task_id}`).
- User explicitly requested a pause or asked a clarifying question.

### Resuming After Pause

The orchestrator reads the user's resolution from the state file and re-evaluates
the gate that triggered the pause. The task status is then updated to `running`.

---

## Fail Recovery

Fail the task (status: `failed`) ONLY when:
- The human gate received a "Stop" or "Abort" decision.
- The environment cannot be resolved (e.g., git branch deleted).
- A strict gate fails after all recovery paths are exhausted.

### Re-starting After Fail

Failed tasks can be restarted from a specific stage if upstream outputs are still
valid. The orchestrator re-initializes the state from the target stage downstream.
Upstream stages remain `complete`.
