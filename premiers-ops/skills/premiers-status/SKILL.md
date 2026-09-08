---
name: premiers-status
description: >
  Generate the Premiers project status report — what is built, what is unreleased, what is
  left before the release, and the current numbers across all repos. Use when the user asks
  for the state of the project, a status report, where things stand, what has changed since
  last time, or asks to refresh PLATFORM_STATE.
---

# Generate the Premiers status report

Produces one honest picture of the platform from primary sources. The output is either a
written report or an update to `premiers-web/docs/PLATFORM_STATE.md` §0 — ask which if the
user has not said.

Read `references/platform.md` first.

## The discipline

**Every claim comes from code, a command, or a live endpoint — never from another doc.**

This exists because the docs drifted badly. A 2026-07-24 audit found 120 inaccuracies across
the living docs, and a second audit on 2026-09-08 found the same failure had recurred: three
`CLAUDE.md` files and `PLATFORM_STATE.md` §1–§6 were still telling agents to perform a bot
rename, a Railway rename and a Discord server rename that had all been done weeks earlier.
Docs written as plans and never demoted to records are the recurring bug.

So: if you cannot cite a `file:line`, a command's output or an HTTP response, do not assert it.

## Gather

**Release drift** — per repo:
```bash
git fetch -q origin production staging
git log --oneline origin/production..origin/staging | wc -l
git log --format='%h %ad %s' --date=short -10
```

**Counts** — count them, do not copy them from the doc. Routes, pages, migrations, API-client
methods, components, tests. Every number in a stale doc is stale.

**Test and CI reality**:
```bash
npm run build          # in api and web
npx vitest run         # web unit
gh run list --branch staging --limit 3
```

**Live state** — the public endpoints in the reference, both environments. Compare payload
shapes between production and staging: a field present on one and not the other is how you
prove which migrations are live without database access.

**Work** — open issues per repo, the `launch-critical` set, and the board's Status/Priority
distribution.

**Infra** — Railway `environment-status`, the Vercel production deployment's age.

## Report

Structure:

1. **Executive state** — at most a dozen numbered facts. What is true today.
2. **Unreleased** — what sits on staging per repo, and the promotion risk.
3. **Blockers** — with evidence and owner (agent or Luke).
4. **Numbers** — a table, current values only.
5. **Corrections** — anything a doc asserts that you just disproved. This section is the
   point of the exercise; do not omit it when it is empty-looking, verify a few claims
   deliberately so it has content.
6. **Questions only Luke can answer** — credentials, console state, product rulings.

## Writing to PLATFORM_STATE

If updating the doc: put current truth in **§0**, which is authoritative over §1–§6. Do not
rewrite §1–§6 — they are a dated snapshot and their value is that they are dated. Never edit
a dated statement or a decision record into the present tense; those are history.

Anything forward-looking belongs in an issue, not in this doc. The doc's own maintenance rule
is that future tense in it is a bug.
