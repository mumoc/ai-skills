# Jira Initiative Template

Use this template when preparing Jira tickets for an initiative.

```md
# Initiative

## Context
- initiative:
- board/project:
- default sprint or bucket:
- create in Jira now: yes/no
- notes:

## Ticket Inputs
- summary:
- background:
- desired outcome:
- dependencies:
- technical notes:

## Classification
- area: backend | web | mobile | cross-platform | external
- type: Story | Task
- dependency_level: unblocked | blocked
- execution_order: foundation | api | client | follow-up
- coordination_need: single-team | multi-team
- external_dependency: yes | no
- urgency: normal | priority
- target_bucket: ready-to-refine | next-dev-sprint | later

## Draft Ticket
- title:
- summary:
- background:
- acceptance criteria:
- dependencies:
- technical notes:
```

## Working Rules

- Keep `Summary`, `Background`, `Acceptance Criteria`, `Dependencies`, and `Technical Notes` in that order.
- Classify tickets before deciding sprint placement.
- Put enabling backend tickets ahead of dependent client tickets unless there is a clear reason not to.
