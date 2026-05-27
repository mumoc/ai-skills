# Stage Contracts Reference

Loaded by the `gates` skill when identifying which gate applies to a transition.

---

## What a contract defines

A contract is the agreement between two adjacent stages:
- What the upstream stage must produce (output contract).
- What the downstream stage requires as input (input contract).
- Which gate enforces the boundary.
- What gate type applies.

Gates evaluate the upstream output against this contract before the downstream stage
receives anything.

---

## Pipeline stage map

```
[Setup]
    ↓  GATE-S1 (strict) — context must be current
[Extract]
    ↓  GATE-S2 (strict) — ticket minimum viable
[Analyze]
    ↓  GATE-W2 (soft)   — analysis confidence
[Challenge]        [Risk Assessment]     ← parallel when both present
    ↓                   ↓
    └──────── merge ────┘
    ↓  GATE-S3 (strict) — plan approval (after merge)
[Plan]
    ↓  GATE-W3 (soft)   — partial coverage
[Execute (TDD)]
    ↓  
[Reviewer]         [Security]            ← parallel implementation review
    ↓                   ↓
    └──────── merge ────┘
    ↓  GATE-S3.5 (strict) — quality approval (Reviewer)
    ↓  GATE-S3.7 (strict) — security approval (Security)
[Validate]
    ↓  GATE-W4 (soft)   — documentation gap
    ↓  GATE-S4 (strict) — delivery approval
[Deliver]
```

---

## Contracts

### Setup → Extract

**Gate:** GATE-S1 (strict)

Setup must produce:
```json
{
  "context/domain_glossary.md": "exists and has no schema_version mismatch",
  "context/.setup_manifest.json": {
    "structural_hash": "<matches current repo>",
    "gaps": []
  }
}
```

Extract requires: grounding documents loadable and current.

---

### Extract → Analyze

**Gate:** GATE-S2 (strict)

Extract must produce:
```json
{
  "ticket": {
    "id": "string",
    "title": "string",
    "description": "string",
    "actors": ["at least one"],
    "acceptance_signals": ["at least one observable outcome"],
    "raw": "original ticket text"
  },
  "status": "complete | needs_clarification"
}
```

If `status: needs_clarification`: trigger GATE-H1 before advancing.
If required fields are absent: GATE-S2 fails.

Analyze requires: structured ticket with at least one actor and one acceptance signal.

---

### Analyze → Challenge (and Risk Assessment if parallel)

**Gate:** GATE-W2 (soft)

Analyze must produce:
```json
{
  "intent": "string — primary business intent of the ticket",
  "acceptance_criteria": ["list of verifiable criteria"],
  "gaps": ["missing or underspecified areas"],
  "ambiguous_terms": ["terms that could be misinterpreted"],
  "implicit_assumptions": ["assumptions the ticket makes without stating"],
  "confidence": "high | medium | low"
}
```

If `confidence: low` or `ambiguous_terms` count > 3: GATE-W2 triggers.
Challenge and Risk Assessment both receive the full analysis object.

---

### Challenge + Risk Assessment → Plan (merge point)

**Gate:** GATE-S3 (strict)

Both parallel stages must complete before merge. Merge produces:
```json
{
  "critique": {
    "issues": [
      {
        "source": "challenge | risk_assessment",
        "description": "string",
        "severity": "critical | major | minor",
        "status": "unresolved | acknowledged | accepted"
      }
    ],
    "open_questions": ["questions requiring human input"],
    "recommendation": "proceed | proceed-with-caution | blocked"
  }
}
```

If any issue has `severity: critical` and `status: unresolved`: trigger GATE-H2.
If `recommendation: blocked`: GATE-S3 fails until human resolves via GATE-H2.
If no critical issues: GATE-S3 passes pending explicit user approval.

Plan requires: merged critique with no unresolved critical issues and explicit approval.

---

### Plan → Execute (TDD)

Plan must produce:
```json
{
  "tasks": [
    {
      "id": "string",
      "description": "string",
      "type": "implementation | test | documentation | infrastructure",
      "depends_on": ["task ids"],
      "acceptance_criterion_ref": "criterion this task satisfies",
      "coverage": "full | partial",
      "deferred_reason": "string or null"
    }
  ],
  "coverage_summary": {
    "criteria_covered": N,
    "criteria_total": N,
    "deferred": ["list of deferred items"]
  }
}
```

---

### Execute → Reviewer + Security (parallel)

**Gate:** GATE-S3.5 (strict), GATE-S3.7 (strict)

Execute must produce:
- A set of commits (Red, Green, Refactor).
- A final diff of all changes.

Reviewer must produce:
```json
{
  "status": "pass | fail",
  "violations": [
    {
      "severity": "strict | soft",
      "category": "style | tdd | docs | design",
      "location": "file:line",
      "description": "string",
      "correction": "string"
    }
  ],
  "recommendation": "approve | fix"
}
```

Security must produce:
```json
{
  "status": "pass | fail",
  "risks": [
    {
      "severity": "critical | high | medium | low",
      "category": "injection | secrets | privacy | logic",
      "location": "file:line",
      "description": "string",
      "impact": "string"
    }
  ],
  "recommendation": "proceed | block"
}
```

---

### Reviewer + Security → Validate

**Gate:** GATE-S3.5 (strict), GATE-S3.7 (strict)

If Reviewer status is `fail` and any violation is `strict`: GATE-S3.5 fails.
If Security status is `fail` and any risk is `critical | high`: GATE-S3.7 fails.

Validate requires: implementation that has passed both quality and security checks.

---

### Validate → Deliver

**Gates:** GATE-W4 (soft), GATE-S4 (strict)

Validate must produce:
```json
{
  "result": "pass | pass-with-warnings | fail",
  "contradictions": [
    {
      "criterion": "string",
      "plan_output": "string",
      "severity": "blocking | non-blocking"
    }
  ],
  "documentation_delta": {
    "required": true | false,
    "areas": ["list of areas needing doc update"]
  },
  "verify_result": "pass | fail",
  "verify_output": "string"
}
```

If `documentation_delta.required: true`: GATE-W4 triggers.
If any contradiction has `severity: blocking`: trigger GATE-H4.
If `verify_result: fail`: GATE-S4 fails.
If no blocking issues and explicit delivery approval received: GATE-S4 passes.

Deliver requires: clean validation, clean verify, explicit delivery approval.
