# TDD Execution Reference

Loaded by the `engineering-workflow` skill during the execution phase.

---

## Execution steps

1. **Write failing specs first.** Express the intended behavior — not the implementation path.
   Order: happy path first, error paths second, alternate and edge cases last.
2. **Confirm the red state** when the change is high-impact, touches shared behavior, or the
   intended behavior is ambiguous. Show the failing output before committing.
3. **Commit red state** once the failing tests clearly and specifically express intent.
   Message format: `test: add failing specs for <behavior>`
4. **Implement only enough** production code to make the relevant specs pass. Nothing more.
5. **Commit green state** once the target behavior passes.
   Message format: `feat/fix: <what changed>`
6. **Refactor only if tests show a clear need** — duplication, coupling, or naming that obscures
   intent. Keep refactors local to the changed area.
7. **Commit refactor state** once cleanup is verified clean.
   Message format: `refactor: <what was cleaned up>`

---

## When to request approval mid-cycle

Request approval between red and green when:
- The failing tests reveal scope larger than the approved plan.
- A design decision surfaced during implementation that wasn't covered in planning.
- The change touches a shared service, concern, or interface used beyond this ticket.

Do not proceed past the gate until approval arrives.

---

## RSpec guardrails

- Prefer `shared_let` for reused setup values across examples.
- Use `shared_examples` only for genuinely repeated behavior — not to compress unrelated scenarios.
- Keep setup visible in the example group where behavior is being asserted. Avoid hiding important
  context behind opaque helpers.
- Prefer `build` / `build_stubbed` over `create` when persistence is not required.
- Use `before` blocks for stubs and mocks, not for data setup.
- Check `spec/factories` before defining new factories or traits.
- Use `env:` metadata for ENV changes — do not stub `ENV` directly.
- Add the narrowest tests that prove the required behavior change. Do not pad coverage.

---

## Non-RSpec stacks

For JavaScript / TypeScript:
- Prefer integration tests for HTTP handlers and boundary behavior.
- Mock at the boundary (network, filesystem, clock) — not inside domain logic.
- Avoid snapshot tests for business logic. Use explicit assertions.

For Python:
- Use `pytest` fixtures for setup — not `setUp`/`tearDown`.
- Prefer `monkeypatch` and `respx` / `httpx` for boundary mocking.
- One fixture per responsibility. Avoid fixtures that do too much.
