# Dispatch Reference

Loaded by the `orchestrator` skill when preparing to run a stage for a specific task.

---

## What dispatch does

Dispatch is how the orchestrator activates an agent for a target `task_id`. It:
1. Loads the task's state from `.ai/tasks/{task_id}/state.json`.
2. Validates the environment (e.g., git branch) matches the task.
3. Loads the agent's skill file.
4. Builds a scoped payload from task state — only what the agent needs.
5. Hands the payload to the agent.
6. Receives the agent's output.
7. Writes the output back to task state.
8. Triggers gate evaluation.

---

## Dispatch sequence

```
1. Load Task State               → read .ai/tasks/{task_id}/state.json
2. Environment Validation        → for implementation stages, confirm git branch matches
3. Confirm prerequisites         → all upstream stages complete, no blocking gates
4. Load agent skill              → read the agent's SKILL.md
5. Resolve model                 → read model_tier from SKILL.md frontmatter, map to model ID
6. Build scoped payload          → extract only required fields from task state
7. Set stage status: running     → update task state before dispatch
8. Dispatch agent                → pass payload and resolved model, await output
9. Validate output shape         → confirm required fields are present
10. Write output to task state   → set stage status: complete, save state.json
11. Evaluate gate                → load gates skill, run transition gate
12. Route                        → advance, loop-back, human, or fail
13. Append history event         → record what happened (include model used)
```

### Model resolution (step 5)

Read `model_tier` from the agent SKILL.md frontmatter. Look up the model ID from the
tier table in `AGENTS.md` for the active tool. If a `model_overrides` block exists in
the project's `AGENTS.md`, it takes precedence over the global tier defaults.

```
model_tier: fast | balanced | powerful
             ↓
tier table in AGENTS.md  →  concrete model ID for active tool
             ↓
model_overrides in project AGENTS.md  →  overrides tier default if present
```

If `model_tier` is absent from the SKILL.md, default to `balanced`.

Record the resolved model in the history event at step 13 so model selection is
traceable across pipeline runs.

If step 8 fails (output malformed): set stage `status: failed`, do not write to output,
trigger loop-back with a shape-error context block.

---

## Implementation Stage Safety

Before dispatching `plan`, `execute`, or `deliver`, the orchestrator MUST verify:
```bash
git branch --show-current
```
Matches `state.git_branch`. If it doesn't match:
- If no uncommitted changes exist: `git checkout <state.git_branch>`.
- If uncommitted changes exist: PAUSE with a Human Gate to resolve the conflict.

---

## Agent payloads by stage

Each agent receives only the slice of state it needs. Build payloads exactly as defined
here — do not add fields not listed, do not omit required fields.

### Extractor payload

```json
{
  "task": "extract",
  "ticket": {
    "raw": "<full ticket text or Jira content>",
    "source": "jira | text"
  },
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>"
  }
}
```

### Analyzer payload

```json
{
  "task": "analyze",
  "ticket": "<state.stages.extract.output.ticket>",
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>",
    "service_context": "<contents of relevant context/{service}_context.md>"
  },
  "gate_metadata": "<state.gates.active_warnings if any>"
}
```

Service context selection: read `ticket.title` and `ticket.description` to identify
which service namespace is most relevant. Load that context file. If multiple services
are involved, load all relevant ones. If uncertain, load the glossary only and note it
in the dispatch log.

### Challenger payload

```json
{
  "task": "challenge",
  "ticket": "<state.stages.extract.output.ticket>",
  "analysis": "<state.stages.analyze.output>",
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>",
    "service_context": "<relevant service context>"
  },
  "gate_metadata": "<state.gates.active_warnings if any>"
}
```

### Risk Assessment payload

```json
{
  "task": "risk_assessment",
  "ticket": "<state.stages.extract.output.ticket>",
  "analysis": "<state.stages.analyze.output>",
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>",
    "service_context": "<relevant service context>"
  },
  "gate_metadata": "<state.gates.active_warnings if any>"
}
```

Note: Challenger and Risk Assessment receive the same payload snapshot. Neither receives
the other's output during execution.

### Planner payload

```json
{
  "task": "plan",
  "ticket": "<state.stages.extract.output.ticket>",
  "analysis": "<state.stages.analyze.output>",
  "critique": "<state.stages.merge.output.critique>",
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>",
    "service_context": "<relevant service context>"
  },
  "approval": {
    "plan_approved": "<state.approvals.plan_approved>",
    "approved_at": "<state.approvals.plan_approved_at>"
  },
  "gate_metadata": "<state.gates.active_warnings if any>"
}
```

### Validator payload

```json
{
  "task": "validate",
  "ticket": "<state.stages.extract.output.ticket>",
  "plan": "<state.stages.plan.output>",
  "context": {
    "domain_glossary": "<contents of context/domain_glossary.md>"
  },
  "gate_metadata": "<state.gates.active_warnings if any>"
}
```

---

## Output shape validation

Before writing any output to state, confirm these fields are present:

| Stage | Required output fields |
|---|---|
| Extract | `ticket.id`, `ticket.title`, `ticket.actors`, `ticket.acceptance_signals`, `status` |
| Analyze | `intent`, `acceptance_criteria`, `gaps`, `ambiguous_terms`, `confidence` |
| Challenge | `issues[]`, `open_questions[]`, `recommendation` |
| Risk Assessment | `issues[]`, `open_questions[]`, `recommendation` |
| Plan | `tasks[]`, `coverage_summary` |
| Validate | `result`, `contradictions[]`, `documentation_delta`, `verify_result` |

If any required field is missing: treat as malformed output, trigger loop-back with a
shape-error context block listing exactly which fields are absent.

---

## Loop-back dispatch

When routing a loop-back, rebuild the payload with an additional `_loop_context` block:

```json
{
  "_loop_context": {
    "loop_count": "<state.stages.{stage}.attempts>",
    "gate_code": "<gate that triggered the loop>",
    "reason": "<specific reason for the loop>",
    "instruction": "<targeted fix instruction for the agent>"
  }
}
```

Keep `instruction` specific. Bad: "try again". Good: "Re-analyze with focus on resolving
the ambiguous terms: [term1, term2]. If they cannot be resolved from context, mark them
explicitly with `ambiguous: true` on the relevant acceptance criterion."
