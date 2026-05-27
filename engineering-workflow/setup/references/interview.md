# Interview Reference

Loaded by the `setup` skill during the interview phase.

---

## Purpose

The interview fills gaps that harvest cannot answer. It covers business knowledge that
lives in people's heads, not in any file.

Ask only what is missing. Never ask what harvest already answered.

---

## How to conduct the interview

1. State what was found: "Harvest covered X, Y, Z."
2. State what is missing: "I still need A, B, C to produce complete grounding documents."
3. Ask all remaining questions in one batch — do not drip them.
4. Wait for answers before generating any context files.

If harvest covered everything, skip the interview entirely and say so explicitly.

---

## Required coverage

Before the interview is complete, these four areas must be covered:

| Area | Covered when... |
|---|---|
| System purpose | One sentence stating what problem this system solves in business terms |
| Primary actors | User types and external systems that interact with the system |
| Critical business rules | At least one rule per major service namespace that governs behavior |
| Domain terminology | Any term used in a non-standard way that could be misinterpreted |

---

## Question bank

Use only the questions relevant to what is missing. Do not ask all of them.

### System purpose (ask if not found in AI.md or any README)

> In one or two sentences — what business problem does this system solve?
> Answer in terms of the people using it, not the technology.

### Primary actors (ask if not found)

> Who are the main actors in this system?
> Examples: dealership admin, fleet manager, external API client, background job.
> For each actor, what is the one thing they most need the system to do?

### Critical business rules (ask per namespace that has no README or sparse docs)

> For `{namespace}`: what are the 2-3 most important rules governing how it behaves?
> Focus on constraints — things that must always be true, things that can never happen,
> conditions that change the flow.

### Domain terminology (ask if glossary coverage is thin)

> Are there any terms in this codebase that have a specific meaning different from
> their everyday meaning?
> Examples: "contract" meaning X here but Y elsewhere, "reservation" that is not
> the same as a booking.

### Historical decisions (ask if no constraints or caveats were found in any README)

> Are there any important decisions or constraints that are not obvious from the code?
> Examples: "we never delete contracts, only archive them", "legacy records from
> before 2023 are read-only", "this service owns billing but not invoicing".

### Known pain points (optional — ask only for complex systems)

> Are there areas where the current design creates friction or where tickets frequently
> get the behavior wrong?
> This helps the challenge agent know where to focus skepticism.

---

## Interview output format

After the interview, produce a structured summary before generating context files:

```
INTERVIEW SUMMARY

System purpose: <one sentence>

Actors:
  - <actor>: <what they need>
  - <actor>: <what they need>

Business rules by namespace:
  {namespace}:
    - <rule>
    - <rule>
  {namespace}:
    - <rule>

Domain terminology:
  - <term>: <definition in this system>

Historical decisions:
  - <decision or constraint>

Gaps not covered by interview:
  - <namespace or area>: <what is still unknown>
```

Show this summary to the user before writing any context files.
Ask: "Does this look right? Anything to add or correct?"

Wait for confirmation before proceeding to generation.
