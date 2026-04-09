# Parallel Execution Reference

Loaded by the `orchestrator` skill when handling concurrent agent dispatches.

---

## Parallel Stages

The pipeline uses parallel execution in two critical phases to provide balanced,
adversarial perspectives.

### 1. Discovery Phase: Challenge + Risk Assessment
- **Goal**: Find what is wrong with the ticket/analysis before planning.
- **Merge Output**: `critique` object.
- **Gate**: GATE-S3 (Plan Approval).

### 2. Implementation Phase: Reviewer + Security
- **Goal**: Verify quality and safety of the implementation before validation.
- **Merge Output**: `quality_report` object.
- **Gate**: GATE-S3.5 (Quality) and GATE-S3.7 (Security).

---

## Parallel Dispatch Rules

- **Shared Snapshot**: Both agents receive the exact same task state snapshot.
- **No Cross-Talk**: Agents cannot see each other's in-progress work.
- **Independence**: A failure in Agent A does not stop Agent B.
- **Merge Wait**: The orchestrator must wait for both agents to return (or hit the
  timeout/loop limit) before attempting a merge.

---

## Merge Logic

### Critique Merge (Challenge + Risk Assessment)
- Deduplicate issues appearing in both outputs.
- Preserve the highest severity if sources disagree.
- Aggregate all `open_questions` into a unique list.

### Quality Report Merge (Reviewer + Security)
The merge produces a single `quality_report` used by the Validator:
```json
{
  "status": "pass | fail",
  "summary": "...",
  "violations": [...],
  "security_risks": [...],
  "blocking_issues_count": N
}
```
Status is `fail` if either source returned a `fail` or if any strict/critical issue exists.

---

## Handling Parallel Failures

- If Agent A fails (malformed) and Agent B succeeds: loop back Agent A only.
- If both fail: loop back both.
- If one agent hits the loop limit while the other is clean: escalate to a human
  gate with the partial results from the successful agent.
