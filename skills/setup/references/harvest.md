# Harvest Reference

Loaded by the `setup` skill during the harvest phase.

---

## What harvest does

Harvest extracts business-relevant signal from existing documentation without reading
source code files. The goal is maximum signal at minimum token cost.

---

## Source priority

Read sources in this order. Stop adding sources for a namespace once coverage is sufficient.

| Priority | Source | What to extract |
|---|---|---|
| 1 | Namespace `README.md` | Domain concept, business rules, constraints, terminology |
| 2 | Project `AI.md` | Stack, architecture, key patterns, performance notes |
| 3 | Schema file | Entity names and relationships (names only, no column details) |
| 4 | Class-level docblocks | Business rules that drive branching, validation, or fallback |

---

## Reading namespace READMEs

These are the highest-value source. Read every one found during discovery.

Extract regardless of section header name:

**Domain concept** — what business problem does this namespace own? Look for: opening
paragraph, "What", "Overview", "Purpose" sections, or any introductory prose.

**Business rules** — constraints governing behavior. Look for: "Rules", "Business Rules",
"Constraints", "Behavior", "Logic", "Policies", numbered or bulleted rule lists, and
any prose that says "must", "cannot", "always", "never", "only when", "requires".

**Constraints and edge cases** — known limitations, historical decisions, gotchas.
Look for: "Edge Cases", "Limitations", "Known Issues", "Notes", "Caveats", warning
blocks, or any prose that says "except", "unless", "legacy", "deprecated", "workaround".

**Domain terminology** — words that have specific meaning in this system. Look for:
defined terms in bold, a glossary section, or any word used in a non-standard way.

**Do not extract:**
- Step-by-step implementation instructions.
- Code examples (unless they illustrate a business rule not stated in prose).
- Dependency lists, setup commands, or operational runbooks.
- Anything that describes *how* the code works rather than *why* it exists.

---

## Reading the schema file

Read entity names and their associations only. Do not extract column names, types,
indexes, or constraints unless they directly encode a business rule (e.g. a unique
constraint that enforces a domain invariant).

Extract:
```
Entity: Contract
  belongs_to: Dealership
  belongs_to: Renter
  has_many: Reservations
  has_one: BillingRecord
```

Stop there. Do not read further into the schema.

---

## Reading class-level docblocks

Scan for class-level docblocks only. Skip method-level docblocks unless:
- They describe a critical domain rule not captured anywhere else.
- The method name alone does not convey the business constraint.

Extract only docblocks that contain at least one of:
- A business rule stated in plain language.
- A non-obvious constraint or invariant.
- A domain concept definition.

Skip docblocks that only restate the class name or describe code structure.

---

## Handling missing or sparse documentation

If a namespace has no README and no meaningful docblocks:

1. Note it as a gap in the harvest output.
2. Add a `[NEEDS INPUT: <namespace>]` placeholder in the generated context file.
3. Add a targeted interview question for that namespace in Step 4.

Do not attempt to infer business rules from source code to fill the gap. Mark it
and ask.

---

## Token budget per namespace

Keep harvest output per namespace under 400 tokens before passing to generation.
If a README is long, summarize — do not pass raw content to the generator.

Summarization rules:
- Preserve all business rules verbatim (they are the most important signal).
- Summarize descriptive prose into one sentence.
- Drop implementation steps entirely.
- Drop code examples unless they encode a rule not stated in prose.
