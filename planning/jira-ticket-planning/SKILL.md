---
name: jira-ticket-planning
description: Draft, classify, and optionally create Jira tickets from an initiative plan. Use when the user provides a plan and wants Jira-ready tickets, wants help shaping a plan into tickets, wants sprint-placement guidance, or wants approved tickets created in Jira.
---

# Jira Ticket Planning

Use this skill for initiative-to-ticket workflows:

- the user already has a plan and wants ticket drafts
- the user wants help turning an emerging plan into tickets
- the user wants sprint-placement guidance for those tickets
- the user wants approved tickets created in Jira

Keep the main workflow here. Load references only when needed:

- read [references/jira_ticket_conventions.md](references/jira_ticket_conventions.md) for ticket section order, classification attributes, and sequencing heuristics
- read [references/jira_initiative_template.md](references/jira_initiative_template.md) when you need a structured initiative intake or a reusable ticket template

## Workflow

### 1. Normalize the initiative

Extract:

- initiative/theme
- project or board
- whether the request is draft-only or create-in-Jira
- default sprint or backlog bucket
- constraints on issue types, prefixes, epic, labels, components, status, or sprint

If the user already has a plan, do not re-plan it unless there is a material gap.

### 2. Classify each ticket before drafting it

Assign the planning attributes defined in `references/jira_ticket_conventions.md`.

Use classification to decide sequencing and sprint placement. Foundation or API enablers usually come before dependent client tickets.

### 3. Apply ticket structure

Use the section order from `references/jira_ticket_conventions.md`.

Write for planning clarity:

- `Summary` for the core outcome
- `Background` for why the work exists
- `Acceptance Criteria` for observable completion
- `Dependencies` for sequencing
- `Technical Notes` for implementation boundaries, systems, identifiers, or integration constraints

Do not repeat the same business intent across every section.

### 4. Stop at drafts or create in Jira

If the user wants drafts only:

- return markdown tickets
- keep titles, issue types, and dependencies explicit

If the user wants Jira creation:

- verify the target Jira project or board details first
- confirm required fields such as project, issue type, sprint, status behavior, epic, labels, and components
- create issues only after the plan is approved enough
- validate one issue first if sprint field shape or workflow behavior is uncertain

## Output

For draft-only requests, provide ticket markdown plus brief sequencing notes when helpful.

For Jira creation, report:

- created issue keys
- confirmed status
- confirmed sprint or bucket
- assumptions used

## Use This Skill When

- "Turn this plan into Jira tickets"
- "Help me plan the tickets for this initiative"
- "Draft backend, web, and mobile tickets from this plan"
- "Which sprint should these tickets go into?"
- "Create these tickets in Jira once the plan looks right"
