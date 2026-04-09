# Strict Gates Reference

Loaded by the `gates` skill when evaluating hard-stop conditions.

---

## What a strict gate does

A strict gate blocks the pipeline entirely when its condition fails. There is no
degraded mode, no warning, no continuation. The pipeline stops and the condition
must be resolved before anything proceeds.

---

## Strict gate definitions

### GATE-S1: Setup complete

**Position:** Before any pipeline stage on a repo.
**Blocks:** Everything.

Conditions (all must pass):
- `context/.setup_manifest.json` exists.
- `schema_version` in manifest matches current skill version.
- `structural_hash` in manifest matches computed hash of current repo state.
- No `[NEEDS INPUT: ...]` gaps exist in `context/domain_glossary.md` for entities
  referenced by the current ticket.

Recovery: run setup skill, then re-evaluate this gate.

---

### GATE-S2: Ticket minimum viable

**Position:** Extract → Analyze.
**Blocks:** Analysis and all downstream stages.

Conditions (all must pass):
- Ticket has at least one identifiable actor or subject.
- Ticket has at least one observable outcome or acceptance signal.

Recovery: human provides missing fields, re-run extract stage, re-evaluate gate.

---

### GATE-S3: Plan approval

**Position:** Challenge → Plan.
**Blocks:** Implementation planning.

Conditions (all must pass):
- Challenge stage produced a `critique` object with no `status: unresolved_critical` items.
- If critical items exist: a human gate (GATE-H2) was evaluated and the user resolved
  or explicitly accepted each critical item.
- Explicit user approval was received for the action path.

Recovery: human resolves critical issues, re-evaluate this gate.

---

### GATE-S3.5: Quality approval (Reviewer)

**Position:** Execute → Validate.
**Blocks:** Final validation and delivery.

Conditions (all must pass):
- Reviewer agent status is `pass`.
- No violations with `severity: strict` exist in the reviewer output.
- All `strict` violations from previous attempts have been addressed in the current diff.

Recovery: loop back to implementation to fix style/TDD/doc violations.

---

### GATE-S3.7: Security approval (Security)

**Position:** Execute → Validate.
**Blocks:** Final validation and delivery.

Conditions (all must pass):
- Security agent status is `pass`.
- No risks with `severity: critical` or `severity: high` exist in the security output.

Recovery: loop back to implementation to address security vulnerabilities.

---

### GATE-S4: Delivery approval

**Position:** Validate → Deliver.
**Blocks:** Push and PR creation.

Conditions (all must pass):
- Validate stage produced no `status: contradiction` items.
- Verify skill passed clean (no lint violations, no test failures).
- Explicit user delivery approval was received in the conversation.

Recovery: fix the specific failure, re-evaluate this gate.

---

## Strict gate evaluation checklist

When evaluating any strict gate, confirm:

- [ ] All conditions for this gate are checked — not just the first one that passes.
- [ ] Failure output names the specific condition that failed, not a generic error.
- [ ] Recovery path is stated explicitly in the failure output.
- [ ] Pipeline state is not advanced until all conditions pass.
