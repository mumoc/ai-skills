---
name: setup
description: One-time repository setup that produces grounding documents consumed by all agents in the engineering workflow. Run before any agentic pipeline. Scans the repository structure, harvests existing documentation, conducts a short business logic interview, and writes context files to context/. Skipped automatically when context/ is current. Re-run when the system changes structurally.
---

# Setup

Use this skill before running any agentic pipeline on a repository.

## Example invocations

- "Run setup on this repo."
- "Generate the grounding documents."
- "The context is stale, re-run setup."
- "Bootstrap the agent context for this project."

## References

- [references/harvest.md](references/harvest.md) — how to extract signal from existing docs and code
- [references/interview.md](references/interview.md) — the business logic interview questions
- [references/output_format.md](references/output_format.md) — grounding document structure and schemas

---

## When to run

**Run once before the first agentic workflow on a repo.**

Re-run when:
- New services, bounded contexts, or major namespaces are added.
- Core business rules change materially.
- The `context/.setup_manifest.json` reports a structural drift (see Gate below).

Skip when:
- `context/.setup_manifest.json` exists and drift is below threshold.
- The user explicitly says "skip setup" or "use existing context."

---

## Lifecycle

```
1. Gate check       → is existing context current enough?
2. Discover         → index documentation and code structure
3. Harvest          → extract signal from existing docs
4. Interview        → ask only what harvest could not answer
5. Generate         → write grounding documents
6. Manifest         → write .setup_manifest.json
7. Confirm          → report what was produced and any gaps
```

---

## Step 1 — Gate check

Look for `context/.setup_manifest.json`.

If it exists, read it and check:
- `schema_version` matches current skill version (`1.0`).
- `completed_at` is present.
- `structural_hash` matches the current structural fingerprint.

**Compute structural fingerprint:**
Count of models/entities, count of service namespaces, count of top-level directories in `app/`
or equivalent. Hash these three numbers as a string: `"<models>:<services>:<top_dirs>"`.

| Condition | Action |
|---|---|
| No manifest | Proceed with full setup. |
| Manifest exists, hash matches | Report "Context is current." Stop unless user forces re-run. |
| Manifest exists, hash drifted | Report what changed. Ask user: "Re-run full setup or update affected sections only?" |
| Schema version mismatch | Run full setup. Overwrite existing context. |

---

## Step 2 — Discover

Build an index of the repository before reading any content. Do not read file contents yet.

**Find:**
- All `README.md` files (any depth) — these are namespace domain docs.
- All files matching YARD doc patterns (`app/**/*.rb`) — for class-level docblocks.
- All files matching JSDoc patterns (`src/**/*.{js,ts}`) — for JS/TS projects.
- All docstring candidates (`**/*.py`) — for Python projects.
- `AI.md` at the project root — stack overview and commands.
- Schema files: `db/schema.rb`, `*.prisma`, `openapi.yaml`, `openapi.json`, `*.graphql`.
- Top-level service directories: `app/services/`, `app/workers/`, `app/models/`, or equivalent.

**Build a discovery map:**
```
{
  "readme_files": [...paths],
  "schema_file": "path or null",
  "ai_md": "path or null",
  "service_namespaces": [...top-level dirs under app/services/ or equivalent],
  "model_count": N,
  "stack": "rails | node | python | mixed"
}
```

Report the discovery map to the user before proceeding. Confirm it looks complete.

---

## Step 3 — Harvest

Read [references/harvest.md](references/harvest.md) for extraction rules.

Process in this order:

1. **Project `AI.md`** — extract stack, architecture overview, key patterns.
2. **Schema file** — extract entity names and relationships (names and associations only,
   not column details).
3. **Namespace READMEs** — extract domain concept, business rules, and usage from each.
   Do not summarize implementation steps — extract intent and rules only.
4. **Docblocks** — extract only class-level docblocks that contain business rules or
   intent statements. Skip method-level docblocks unless they describe a critical domain rule.

Signal to extract from each README regardless of its section headers:
- What domain concept does this namespace own?
- What are the business rules governing behavior?
- What are the known constraints, edge cases, or historical decisions?
- What terminology is domain-specific?

Do not require a specific header like "Business Rules." Read for intent across all sections.

---

## Step 4 — Interview

Read [references/interview.md](references/interview.md) for the full question bank.

Ask only questions that harvest could not answer. Before asking each question, state what
was found and what is still missing.

**Minimum required coverage before skipping interview:**
- [ ] System purpose answered (what problem does this solve, in one sentence)
- [ ] Primary actors identified (who uses it and how)
- [ ] At least one critical business rule per service namespace documented
- [ ] Domain-specific terminology that could be misinterpreted is listed

If all four are covered by harvest, skip the interview entirely and state that explicitly.

Ask all remaining questions in one batch. Do not drip them one at a time.

---

## Step 5 — Generate

Read [references/output_format.md](references/output_format.md) for document structure.

Write these files:

```
context/
  domain_glossary.md          ← always written, always loaded by all agents
  {service}_context.md        ← one per major service namespace
  .setup_manifest.json        ← machine-readable setup state
```

For repos with a single service (non-polyrepo), write one `app_context.md` instead of
per-service files.

**Generation rules:**
- Write in plain language optimized for LLM reasoning, not human prose.
- Lead every section with rules and constraints — not descriptions of code structure.
- Mark gaps explicitly: if a business rule section could not be filled from harvest or
  interview, write `[NEEDS INPUT: <what is missing>]` so future agents know the limit.
- Never invent business rules. Only write what was found or explicitly stated.
- Keep each context file under 800 tokens. If a namespace is too large, split it.

---

## Step 6 — Manifest

Write `context/.setup_manifest.json`:

```json
{
  "schema_version": "1.0",
  "completed_at": "<ISO timestamp>",
  "structural_hash": "<models>:<services>:<top_dirs>",
  "files_produced": [
    "context/domain_glossary.md",
    "context/app_context.md"
  ],
  "harvest_sources": [
    { "path": "app/services/contracts/README.md", "type": "namespace_readme" },
    { "path": "db/schema.rb", "type": "schema" }
  ],
  "interview_conducted": true,
  "gaps": [
    "Billing service: business rules not documented — NEEDS INPUT"
  ],
  "skill_version": "1.0"
}
```

---

## Step 7 — Confirm

Report to the user:

- Files written (list with one-line description of each).
- Sources harvested (count of READMEs, docblocks, schema).
- Interview questions asked and answered (or "interview skipped — harvest was sufficient").
- Gaps that could not be filled — flagged for follow-up.
- Structural hash written (so the user knows what triggers a re-run).

Ask: "Should I fill any of the flagged gaps now before we proceed?"

---

## Hard rules

- **Never invent domain knowledge.** If something is unknown, mark it as a gap.
- **Never read entire source files for harvesting.** Read READMEs and docblocks only.
  Deep-dive into source only when a specific business rule needs verification.
- **context/ is owned by this skill.** Other agents read from it but never write to it.
  Updates to context go through a setup re-run or a targeted update with user approval.
- **Do not create context/ files outside this skill.** Agents that discover missing context
  should flag it and request a setup update — not patch context files themselves.
