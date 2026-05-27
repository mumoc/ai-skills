# Soft Gates Reference

Loaded by the `gates` skill when evaluating warning-level conditions.

---

## What a soft gate does

A soft gate allows the pipeline to continue when its condition is not fully met, but
attaches a structured warning to the payload. Downstream agents receive the warning
and adjust their behavior accordingly. The warning persists until the pipeline completes
or is explicitly cleared by a human gate resolution.

Soft gates never silently pass degraded output. The warning must be present in `_gate.warnings`.

---

## Soft gate definitions

### GATE-W1: Context confidence

**Position:** Before Analyze stage.
**Triggers when:** Setup manifest exists but structural hash has drifted slightly
(model count changed by ≤ 2, no new service namespaces).

Behavior: proceed with warning.

Warning payload:
```json
{
  "code": "GATE-W1",
  "message": "Grounding document may be slightly stale. Repo structure has changed since last setup.",
  "detail": "Model count delta: {N}. No new namespaces detected.",
  "recommendation": "Results are likely accurate. Re-run setup if analysis feels off."
}
```

Downstream effect: Analyzer and Challenger agents treat domain rules as probable, not
certain. They flag any assumption that depends on a recently added entity.

---

### GATE-W2: Analysis confidence

**Position:** Analyze → Challenge.
**Triggers when:** Analyzer produces output with `confidence: low` or flags more than
3 ambiguous terms that could not be resolved from the grounding document.

Behavior: proceed with warning.

Warning payload:
```json
{
  "code": "GATE-W2",
  "message": "Analysis confidence is low. Multiple terms could not be resolved from context.",
  "unresolved_terms": ["term1", "term2"],
  "recommendation": "Challenger should treat these terms as potential misinterpretations."
}
```

Downstream effect: Challenger agent prioritizes challenging assumptions around unresolved
terms before addressing other issues.

---

### GATE-W3: Partial plan coverage

**Position:** Plan → Validate.
**Triggers when:** Planner produces a plan that covers all acceptance criteria but
flags one or more items as `coverage: partial` (e.g. an edge case deferred to a
follow-up ticket).

Behavior: proceed with warning.

Warning payload:
```json
{
  "code": "GATE-W3",
  "message": "Plan has partial coverage. Some items are deferred.",
  "deferred_items": ["item1", "item2"],
  "recommendation": "Validator should confirm deferred items are intentional and tracked."
}
```

Downstream effect: Validator confirms deferred items are explicitly acknowledged in the
plan output, not silently missing.

---

### GATE-W4: Documentation gap

**Position:** Validate → Deliver.
**Triggers when:** Validator detects that the change materially affects a behavior,
flow, or integration contract but no documentation update was included in the plan.

Behavior: proceed with warning.

Warning payload:
```json
{
  "code": "GATE-W4",
  "message": "Documentation may need updating.",
  "affected_areas": ["area1", "area2"],
  "recommendation": "Review nearest README or workflow doc before delivery."
}
```

Downstream effect: Delivery stage includes documentation review as a required step
before calling work complete.

---

## Soft gate evaluation rules

- Attach all triggered warnings to `_gate.warnings` — do not suppress multiple warnings.
- A stage that triggers multiple soft gates continues with all warnings attached.
- Soft gate warnings are cumulative across stages. A warning from GATE-W1 that is not
  resolved remains in the payload through all downstream stages.
- A warning is only cleared when: a human gate explicitly resolves it, or a re-run of
  the triggering stage produces clean output.
- Never convert a soft gate to a strict gate automatically. If a warning persists through
  three stages unresolved, trigger GATE-H3 (human escalation for accumulated warnings).
