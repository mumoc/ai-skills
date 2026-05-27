# Delegation Reference

Loaded by the `engineering-workflow` skill when multi-agent coordination is needed.

---

## What the main agent never delegates

These responsibilities stay with the main agent regardless of complexity or parallelism:

- Task analysis and clarifying questions
- Approval checkpoints (plan gate and delivery gate)
- Integration of delegated outputs into the main change
- Final verification before delivery
- PR preparation and review decisions

Delegating any of these is a design error, not an optimization.

---

## When delegation is appropriate

Delegate only after the action path is approved. Do not use delegation to avoid design decisions
or to parallelize unresolved ambiguity.

Delegate when:
- A bounded read-only research task can run in parallel without blocking the plan approval.
- The approved plan has clearly disjoint implementation slices that do not share write scope.

---

## Agent roles

**Explorer** — read-only research agent.
- Scans the codebase, maps file sets, finds nearest existing patterns.
- Never writes code or tests.
- Returns a structured summary the main agent uses for planning or implementation.

**Worker** — isolated implementation agent.
- Owns a single disjoint slice: one bounded set of files with no overlap with other workers.
- Follows the same TDD-first, minimal-design, existing-pattern rules as the main agent.
- Returns completed work for main agent integration and verification.

---

## Delegation patterns

**Good patterns:**
- One explorer finds nearest existing patterns while another explorer maps the affected file set.
- One worker owns model and model-spec changes. Another worker owns service and service-spec
  changes. File sets do not overlap.
- An explorer reads integration contracts from a cross-repo README while the main agent plans.

**Bad patterns:**
- Multiple workers editing the same spec or service file.
- Delegating unresolved product or scope decisions.
- Handing off the main orchestration of the ticket to a sub-agent.
- Delegating before the plan is approved — workers must know exactly what to build.

---

## Delegation contract

When spawning a worker or explorer, provide explicitly:

1. **Role** — explorer or worker.
2. **Task** — single, bounded, unambiguous instruction.
3. **Scope** — exact files or directories owned. Workers must not touch files outside this scope.
4. **Rules** — TDD-first, minimal design, existing patterns, no new abstractions.
5. **Output format** — what the main agent expects back (summary, code diff, test results, etc.)

A delegation without an explicit scope contract is invalid.
