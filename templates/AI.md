# AI.md

This file provides guidance to the Agent when working with code in this repository.

If `AI.local.md` exists, read it after this file for local-only overrides. `AI.local.md` should be gitignored.

## Overview

- Project: `<project-name>`
- Purpose: `<one-paragraph description of what this repo does>`
- Stack: `<languages, frameworks, runtime versions>`
- Main runtime: `<local, docker, cloud function, mobile app, monorepo, etc.>`

## Working Rules

- Search the codebase before implementing. Reuse existing patterns with the smallest reasonable change.
- Keep diffs minimal and localized. Do not mix feature work with drive-by refactors.
- Be direct about uncertainty. If behavior is unclear, say what needs to be verified.
- Prefer codebase truth over stale documentation. If docs and code disagree, follow the code and note the mismatch.
- Do not create new documentation files unless explicitly asked.
- Ask before editing migrations, dependency manifests, CI workflows, Docker files, infrastructure code, or generated files.

## Commands

List the commands the Agent should prefer when working here.

```bash
# Setup
<setup-command>

# Development
<dev-command>

# Lint
<lint-command>

# Tests
<test-command>
<single-test-command>

# Code generation
<codegen-command>
```

If the repository supports more than one workflow, document both. Example: local and Docker.

## Architecture

Document only the parts the Agent needs to navigate the codebase safely.

```text
<key-path-1>   # <what lives here>
<key-path-2>   # <what lives here>
<key-path-3>   # <what lives here>
```

Include important patterns already used in the repo, for example:

- service objects
- presenter/container split
- feature-based modules
- background job boundaries
- versioned APIs
- generated clients or schemas

## Generated Code Boundaries

List files or directories that must never be edited by hand.

- `<generated-path-or-pattern>`
- `<generated-path-or-pattern>`

For each generated surface, include the regeneration command.

## Testing And Verification

- Add or update regression tests for behavior changes and bug fixes.
- Prefer targeted tests for changed areas before running broad suites.
- Run lint and the relevant tests before considering work complete.
- If a ticket includes acceptance criteria, map each criterion to at least one test.
- In summaries and PRs, state the exact commands used for verification.

Repo-specific testing notes:

- `<test-harness-gotcha>`
- `<timezone, feature flag, network stubbing, or browser requirement>`

## Environment And Secrets

- Document which env files are committed and which are local-only.
- Keep secrets out of the repository, prompts, and committed config.
- Use `<secret-manager>` or the approved secret store for credentials.
- If there are multiple environments, document how to switch between them safely.

Example:

- `.env.example` is committed
- `.env.local` is gitignored
- `<env-switch-command>` prepares the active local environment

## Cross-Repo Or Source-Of-Truth Rules

If this repository depends on other local repositories or services, document where the assistant should look first.

- Behavior questions should be answered from `<owning-repo-or-path>`, not from copied docs.
- If a feature spans multiple repos, prefer matching branch names and verify integration points explicitly.
- Prefer local repositories over web search when the source of truth is available locally.

## PR Expectations

- Use short, imperative commit messages unless the project requires another format.
- Summaries should include what changed, why, and how it was verified.
- Include screenshots or UX notes for UI changes when relevant.
- Mention any follow-up risks, skipped checks, or assumptions.
