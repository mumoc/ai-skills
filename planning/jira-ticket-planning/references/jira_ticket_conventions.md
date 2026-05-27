# Jira Ticket Conventions

## Ticket Structure

Use this section order when drafting tickets:

1. `Summary`
2. `Background`
3. `Acceptance Criteria`
4. `Dependencies`
5. `Technical Notes`

## Sprint Placement Attributes

Use these attributes to decide which sprint or backlog bucket a ticket belongs in:

- `area`
  - `backend`
  - `web`
  - `mobile`
  - `cross-platform`
  - `external`
- `type`
  - `Story`
  - `Task`
- `dependency_level`
  - `unblocked`
  - `blocked`
- `execution_order`
  - `foundation`
  - `api`
  - `client`
  - `follow-up`
- `coordination_need`
  - `single-team`
  - `multi-team`
- `external_dependency`
  - `yes`
  - `no`
- `urgency`
  - `normal`
  - `priority`
- `target_bucket`
  - `ready-to-refine`
  - `next-dev-sprint`
  - `later`

## Practical Planning Rules

- Backend or API enablers usually go before web or mobile tickets that depend on them.
- Cross-platform work should call out sequencing explicitly in `Dependencies`.
- External confirmation tickets should usually stay out of active build sprints until resolved.
- Client-only display changes can go into the same sprint once API behavior is stable.
