---
name: verify
description: Run lint and tests before declaring work done. Invoke after every TDD cycle and before any "done" declaration. Reads /verify from the project AI.md; falls back to stack auto-detection.
---

# Verify

Use this skill to confirm work is complete. It is a hard gate — work is never done until verify
passes clean.

## When to invoke

- After every TDD red/green/refactor cycle
- Before declaring a feature, fix, or refactor complete
- Whenever the user asks "is this done?" or "does this pass?"

## Step 1 — Find the verify command

Read the project's `AI.md`. Look for a `/verify` section or a block that defines the lint
and test commands explicitly.

If found, run exactly those commands and skip to Step 3.

## Step 2 — Auto-detect stack (fallback)

If no `/verify` command is defined, detect the stack from files present in the project root:

| Signal | Linter | Test runner |
|---|---|---|
| `Gemfile` | `bundle exec rubocop` | `bundle exec rspec` |
| `package.json` + jest config | `npx eslint .` or `npx biome check .` | `npx jest --passWithNoTests` |
| `package.json` + vitest config | `npx eslint .` or `npx biome check .` | `npx vitest run` |
| `pyproject.toml` or `setup.py` | `ruff check .` or `flake8` | `pytest` |

Before running, check for linter config files (`.rubocop.yml`, `.eslintrc*`, `biome.json`,
`ruff.toml`) to confirm which linter is active. Do not run a linter that has no config — skip
it and note the absence.

For monorepos or multi-stack projects, run verify for each stack that has changes in scope.

## Step 3 — Run and report

Run the linter first, then the test suite. Report clearly:

```
Lint:  ✓ passed
Tests: ✓ 42 passed, 0 failed
```

or

```
Lint:  ✗ 3 violations
  app/services/foo.rb:12 — Layout/TrailingWhitespace
  app/services/foo.rb:34 — Metrics/MethodLength
  src/utils.ts:7 — no-unused-vars

Tests: ✗ 2 failed
  OrderService#create raises when amount is negative (./spec/services/order_service_spec.rb:45)
  POST /orders returns 422 when payload is missing (./spec/requests/orders_spec.rb:88)
```

## Step 4 — Gate

- All checks pass → work is complete. State this explicitly.
- Any check fails → list every failure with file and line, do not declare done, and address
  failures before proceeding.

## Hard rule

**Work is never done until verify passes clean.** This is not optional and cannot be waived
without explicit user instruction.
