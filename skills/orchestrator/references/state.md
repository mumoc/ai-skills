# Shared State Reference

Loaded by the `orchestrator` skill to manage pipeline state for specific tasks.

---

## Task-Isolated State

To support multiple parallel workflows, state is isolated per task. Each task (usually
mapped to a Jira ticket) has its own state file and its own git branch.

**Storage Location:** `.ai/tasks/{task_id}/state.json`

The orchestrator manages these files and ensures the active task matches the current
git branch before performing any implementation work.

---

## State schema

```json
{
  "task_id": "<Jira ticket ID or unique slug>",
  "pipeline_id": "<uuid>",
  "git_branch": "feature/<task_id>",
  "started_at": "<ISO timestamp>",
  "status": "running | paused | failed | complete",

  "context": {
    "glossary_loaded": true,
    "service_contexts_loaded": ["contracts", "billing"],
    "setup_hash": "<hash from manifest>"
  },

  "stages": {
    "extract": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    },
    "analyze": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    },
    "challenge": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    },
    "risk_assessment": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    },
    "merge": {
      "status": "pending | complete",
      "output": null,
      "completed_at": null
    },
    "plan": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    },
    "validate": {
      "status": "pending | running | complete | failed",
      "output": null,
      "attempts": 0,
      "completed_at": null
    }
  },

  "gates": {
    "history": [
      {
        "gate_code": "GATE-S1",
        "stage_transition": "pre-flight → extract",
        "result": "proceed",
        "warnings": [],
        "evaluated_at": "<ISO timestamp>"
      }
    ],
    "active_warnings": [],
    "human_pauses": []
  },

  "approvals": {
    "plan_approved": false,
    "plan_approved_at": null,
    "delivery_approved": false,
    "delivery_approved_at": null
  },

  "history": [
    {
      "event": "stage_dispatched | stage_complete | gate_evaluated | human_paused | resumed | looped_back",
      "stage": "string",
      "detail": "string",
      "at": "<ISO timestamp>"
    }
  ]
}
```

---

## Mutation rules

**Initialize per task.** When a new task starts, the orchestrator creates its directory
and `state.json`. `git_branch` is derived from `task_id`.

**Branch Enforcement.** Before any stage that modifies the filesystem (Plan, Execute,
Verify, Deliver), the orchestrator MUST verify that the current git branch matches
`state.git_branch`. If it doesn't, it must either switch branches or pause for human
intervention.

**Stage outputs are append-only.** Once a stage writes its output to `stages.{stage}.output`,
that slot is not overwritten. If a stage is retried, increment `attempts` and write the new
output to `stages.{stage}.output` only after the retry completes successfully. On failure,
write `null` and record the error in `history`.

**Gate history is append-only.** Every gate evaluation appends to `gates.history`. Never
remove or modify past entries.

**Active warnings accumulate.** When a soft gate fires, its warning is added to
`gates.active_warnings`. It is only removed when explicitly resolved (human gate resolution
or clean stage re-run). Never clear warnings automatically.

**Approvals are set once.** `plan_approved` and `delivery_approved` are set to `true` only
when the user provides explicit confirmation. They are never reset to `false` during a run.

---

## State access patterns

**Task Selection:**
The user specifies the `task_id`. The orchestrator loads the corresponding `state.json`.
If no `task_id` is provided, the orchestrator should list active tasks and ask for selection.

**Reading for dispatch:**
The orchestrator extracts only the fields a specific agent needs. It never passes the
full state object to an agent. See `references/dispatch.md` for payload construction.

**Checking gate preconditions:**
Before dispatching any stage, the orchestrator checks:
1. All prerequisite stages have `status: complete`.
2. No active strict gate failure blocks the transition.
3. Required approvals are present if the transition requires them.

**Resuming after human pause:**
When the pipeline resumes after a human gate, the orchestrator reads the user's response
from `gates.human_pauses[last]`, updates state accordingly, and re-evaluates the gate
that triggered the pause.
