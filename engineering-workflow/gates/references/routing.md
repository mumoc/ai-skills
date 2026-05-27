# Routing Reference

Loaded by the `gates` skill when determining what happens after gate evaluation.

---

## Routing outcomes

Every gate evaluation produces exactly one of these outcomes:

| Outcome | Meaning | Who acts |
|---|---|---|
| `proceed` | All conditions met. Pass output to next stage. | Orchestrator advances pipeline. |
| `proceed-with-warnings` | Conditions met with caveats. Pass output with warnings attached. | Orchestrator advances. Downstream agents adjust behavior. |
| `loop-back` | Output quality insufficient. Re-run the current stage with context. | Orchestrator re-runs stage. Gate enforces loop limit. |
| `human` | A decision cannot be made automatically. Pause and ask the user. | Orchestrator pauses. Human responds. Pipeline resumes. |
| `fail` | Unrecoverable condition. Pipeline cannot continue. | Orchestrator stops. User must intervene. |

---

## Loop-back rules

### When to loop back

Loop back when:
- Stage output is structurally malformed (missing required fields).
- Stage output contains explicit `status: incomplete` or `needs_retry` flags.
- A soft gate warning points to a condition the current stage could fix with more context.

Do not loop back when:
- The issue requires human input to resolve.
- The loop limit has been reached.
- The failure is in the grounding document, not the stage output.

### Loop limit

**Maximum loops per stage: 2.**

On the first loop: re-run the stage with the gate warning attached as additional context.
On the second loop: if the output is still insufficient, escalate to a human gate instead
of looping again.

Loop count is tracked in `_gate.loop_count`. Never reset it within the same pipeline run.

### Loop-back payload

When routing loop-back, pass the original output plus a context block:

```json
{
  "original_output": { ... },
  "_loop_context": {
    "loop_count": 1,
    "gate_code": "GATE-W2",
    "reason": "3 unresolved terms in analysis output",
    "instruction": "Re-analyze with focus on resolving: term1, term2, term3. If they cannot be resolved from context, mark them explicitly as ambiguous."
  }
}
```

---

## Human gate definitions

Human gates pause the pipeline and surface exactly one question to the user.
Never ask multiple questions in a single human gate. If multiple decisions are needed,
prioritize the most blocking one.

### GATE-H1: Ambiguous ticket intent

**Triggers when:** Extract stage cannot determine primary intent from the ticket.
**Question format:**

```
The ticket references "{term or concept}" which has more than one possible interpretation
in this system.

Which did you mean?
  A) {interpretation A — one sentence}
  B) {interpretation B — one sentence}
  C) Neither — clarify: ___
```

Resume: re-run Extract with the chosen interpretation as context.

---

### GATE-H2: Critical challenge issues

**Triggers when:** Challenge stage finds items with `status: unresolved_critical`.
**Question format:**

```
The challenge stage found {N} critical issue(s) that block planning.

Critical issue: {issue description}
  → {what makes it critical}
  → {what needs to be decided}

How should we proceed?
  A) {resolution option A}
  B) {resolution option B}
  C) Accept the risk and proceed anyway
```

Resume: mark the issue as resolved with the chosen option, re-evaluate GATE-S3.

---

### GATE-H3: Accumulated unresolved warnings

**Triggers when:** Three or more soft gate warnings have accumulated across stages
without resolution.
**Question format:**

```
Multiple warnings have accumulated through the pipeline that haven't been resolved:

  1. {GATE-Wx}: {warning message}
  2. {GATE-Wx}: {warning message}
  3. {GATE-Wx}: {warning message}

Do you want to:
  A) Address these before continuing
  B) Acknowledge and proceed — I accept the reduced confidence
```

Resume: if A, route to the appropriate resolution for each warning. If B, clear warnings
and mark them as user-accepted in the payload.

---

### GATE-H4: Validation contradiction

**Triggers when:** Validate stage finds a contradiction between the plan and the
original ticket acceptance criteria that cannot be automatically resolved.
**Question format:**

```
The validation stage found a contradiction between the plan and the ticket.

Ticket says: "{acceptance criterion}"
Plan produces: "{what the plan actually delivers}"

How should we resolve this?
  A) Update the plan to meet the original criterion
  B) The ticket criterion was wrong — proceed with what the plan delivers
  C) Partial: {describe what partial resolution looks like}
```

Resume: route to plan stage with the resolution as context, or advance with updated
acceptance understanding.

---

## Fail routing

Route to `fail` only when:
- Setup is missing and the user explicitly declines to run it.
- A strict gate has failed more than once after recovery attempts.
- A human gate received a response that makes the pipeline logically impossible to continue.

Fail output format:
```
PIPELINE FAILED
Stage: {stage name}
Gate: {gate code}
Reason: {specific, non-generic reason}
State preserved: {yes/no — whether partial outputs are available for inspection}
Recovery: {what the user must do to restart or repair}
```
