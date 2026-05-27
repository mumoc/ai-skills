# Completion Bar

Loaded by the `engineering-workflow` skill before declaring work done.

This is a hard gate. All conditions must pass. If any fail, resolve them before proceeding.

---

## Gate conditions

### Analysis and planning
- [ ] The task was read directly (Jira ticket or full description) — not summarized by the user.
- [ ] Clarifying questions were asked and resolved before implementation started.
- [ ] The action path was explicitly approved before any code was written.

### Execution
- [ ] Tests were written or updated before the implementation change.
- [ ] The change followed an existing repo pattern, or a narrow deviation was justified explicitly.
- [ ] No unnecessary abstractions, layers, or helpers were introduced.
- [ ] Each meaningful checkpoint has its own commit: red, green, refactor, and review follow-up.

### Delegation (if used)
- [ ] Every delegated task had bounded scope and a clear ownership contract.
- [ ] No delegated task shared write scope with another agent or with the main agent.
- [ ] The main agent integrated and verified all delegated outputs before delivery.

### Verification
- [ ] The `verify` skill was run and passed clean.
- [ ] All lint violations are resolved.
- [ ] All test failures are resolved.
- [ ] No tests were skipped or marked pending to force a pass.

### Documentation
- [ ] Nearest existing documentation was reviewed for staleness.
- [ ] If the change materially alters behavior, flow, integration contracts, or operational
     setup — the nearest existing README or workflow doc was updated in the same change.
- [ ] No new documentation files were created unless explicitly requested.

### Delivery gate (pre-push)
- [ ] Explicit delivery approval was received before pushing or opening a PR.
- [ ] The PR summary includes: what changed, why, how it was verified, and follow-up risks.

---

## Gate routing

| Result | Action |
|---|---|
| All pass | Work is complete. Proceed to delivery. |
| Verify fails | Fix failures. Re-run verify. Do not proceed. |
| Documentation gap found | Update the nearest doc. Re-check this bar. |
| Missing approval | Stop. Request approval. Do not proceed past the gate. |
| Delegation contract violated | Re-integrate correctly. Re-run verify. |

---

## Hard rule

**Do not declare work done until every condition above is checked and passing.**
This bar is not a suggestion. It cannot be waived without explicit user instruction.
