---
name: code-quality
description: Code writing standards, full-stack debugging approach, code review priorities, and testing guidelines. Use when writing, refactoring, or reviewing code, or when assessing quality of a change.
metadata:
  author: yazilim-vip
  version: "0.1.0"
  status: "stable"
---

# Code Quality

## Writing Code

- Read the project `AGENTS.md` before running any command — it may specify prerequisites not obvious from build files
- Read existing code before writing — understand patterns before changing them
- Follow existing patterns in a codebase before introducing new ones
- Do not add features, refactor, or improve beyond what was asked
- Verify changes compile/build/pass before declaring done
- Secret credentials must never appear in tool output — verify structure and key names only, never display values

## Full-Stack Debugging

When a feature spans frontend and backend:

1. Read the backend first (controller → service → data layer)
2. Understand what the API accepts and returns
3. Then work on the frontend

- Check backend API before building UI features — confirm the endpoint supports the operation, check for guards (completed, archived, locked)
- If the UI runs against a remote API, undeployed backend changes are invisible — flag this immediately

## Code Review Priorities

1. **Correctness** — does it work as intended?
2. **Security** — OWASP top 10, input validation, auth checks
3. **Safety** — breaking changes, data integrity
4. **Maintainability** — readability, patterns, complexity
5. **Performance** — only if there's a measurable concern

## What to Flag

- Logic errors and edge cases
- Security vulnerabilities
- Exposed secrets (immediate escalation)
- Breaking changes to public APIs
- Missing error handling at system boundaries
- Convention violations

## What to Skip

- Style preferences (defer to formatters)
- Minor naming opinions
- Missing comments on self-evident code
- Hypothetical future problems

## Testing

- Integration tests over mocks where feasible
- E2E tests for critical user paths
- Never skip tests to ship faster
- Never modify source code during repo imports (e.g. monorepo migration) — zero diff against original; changes go in separate commits
