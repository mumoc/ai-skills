---
name: gates
description: Gate evaluation logic for agentic pipelines. Gates are checkpoints between pipeline stages that decide whether to proceed, pause, loop back, or escalate to a human. Load this skill when the orchestrator needs to evaluate stage output before advancing. Not loaded by individual agents — only the orchestrator uses it.
---

# Gates

Gates are the boundaries between pipeline stages. They evaluate the output of one stage
and decide what happens before the next stage receives it.

An agent produces output. A gate evaluates it. The orchestrator acts on the gate result.
Agents never know gates exist.

## References

- [references/strict.md](references/strict.md) — strict gate definitions and conditions
- [references/soft.md](references/soft.md) — soft gate definitions and conditions
- [references/routing.md](references/routing.md) — routing logic, loop limits, escalation rules
- [references/contracts.md](references/contracts.md) — input/output contracts between stages

---

## Gate types

| Type | Behavior |
|---|---|
| **Strict** | Hard stop. Pipeline cannot continue until condition is resolved. |
| **Soft** | Pipeline continues with a warning attached to the payload. |
| **Conditional** | Routes to different paths based on output quality or content. |
| **Human** | Pauses pipeline and surfaces a specific question to the user. |

---

## When to evaluate a gate

Evaluate a gate after every stage completes, before passing output to the next stage.
Do not skip gate evaluation even when output looks clean — the gate is the verification,
not the agent.

---

## Gate evaluation sequence

For each stage transition:

```
1. Receive stage output
2. Identify the gate type for this transition (see references/contracts.md)
3. Evaluate gate conditions (see references/strict.md or references/soft.md)
4. Determine result: proceed | proceed-with-warnings | loop-back | human | fail
5. Route accordingly (see references/routing.md)
6. Attach gate metadata to payload before passing to next stage
```

---

## Gate metadata

Every payload passed between stages carries a `_gate` metadata block:

```json
{
  "_gate": {
    "stage": "analyze",
    "result": "proceed | proceed-with-warnings | loop-back | human | fail",
    "warnings": [],
    "escalation_reason": null,
    "loop_count": 0,
    "evaluated_at": "<ISO timestamp>"
  }
}
```

Downstream agents receive this block alongside the stage payload. Their prompts can
be instructed to adjust behavior based on `result` and `warnings`.

---

## Hard rules

- **Gates evaluate, they do not fix.** If output needs fixing, the gate routes back to
  the agent that produced it. Gates never patch or modify stage output.
- **Gates do not reason about domain content.** They evaluate structure, completeness,
  and explicit flags set by agents — not the quality of domain reasoning.
- **Only the orchestrator runs gates.** Individual agents do not call this skill.
- **Loop limits are enforced by the gate.** An agent that loops more than the allowed
  count triggers an escalation, not another loop.
- **Human gates ask one specific question.** Never dump context at the user. Surface
  exactly the decision that cannot be made automatically.
