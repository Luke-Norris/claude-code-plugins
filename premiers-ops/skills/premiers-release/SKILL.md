---
name: premiers-release
description: >
  Promote Premiers work from staging to production, or check whether a promotion is safe.
  Use when the user asks to promote, release, ship to production, cut a release, deploy to
  prod, check what is unreleased, or asks how far behind production is. Enforces the
  api-before-web ordering, the migration check, and the post-promotion verification walk.
---

# Promote Premiers staging to production

Three repos promote independently but **not in an arbitrary order**. This skill runs the
check, produces the promotion PRs, and verifies afterwards.

Read `references/platform.md` for repo paths, Railway IDs and endpoints.

## The ordering rule — do not violate it

**premiers-api promotes before premiers-web. Always.**

The web derives an event date as `starts_at`, falling back to the `date` field with
`T00:00:00` appended. An older API serialises `tournaments.date` as a full ISO instant, so
appending to it yields an invalid date and every org page renders blank event dates and
collapsed sort. The API change that emits `YYYY-MM-DD` plus `starts_at` must be live first.

The bot promotes last — it is a thin client and its changes are additive.

## Step 1 — establish the gap

For each of `premiers-api`, `premiers-web`, `premiers-discord-bot`:

```bash
git fetch -q origin production staging
git log --oneline origin/production..origin/staging
git log --oneline origin/staging..origin/production
```

The second command must be **empty**. If production has commits staging does not, stop and
report it — someone landed directly on production and staging must be back-merged first.

## Step 2 — check migrations

```bash
git diff --name-status origin/production..origin/staging -- src/db/migrations
```

For every new migration file, confirm by reading it that it is **additive and idempotent**
(`IF NOT EXISTS`, `ADD COLUMN IF NOT EXISTS`, `DROP CONSTRAINT IF EXISTS` before `ADD
CONSTRAINT`). A migration that drops or rewrites data is not safe to promote unattended —
surface it to the user and stop.

Watch for **duplicate numeric prefixes** (two files starting `033_`). The runner sorts by
full filename and records each separately, so both apply, but say so explicitly in the PR
body so the deploy log can be checked.

## Step 3 — check CI and env

```bash
gh run list --branch staging --limit 3
```

Diff `.env.example` between the branches. Any newly required variable must already exist in
the Railway production environment — check with the connector's `list-variables` and report
**names only**, never values. A missing required variable means the deploy boots and dies.

## Step 4 — open the promotion PR

One PR per repo, `staging` → `production`:

```bash
gh pr create --base production --head staging --title "release: promote staging to production (<date>)" --body-file <file>
```

The body must list: the merged PRs being promoted, the migrations being applied, any new env
vars, the ordering constraint, and what to verify after. Write it to a file first — shell
interpolation mangles backticks and `${...}`.

## Step 5 — verify after each merge

Wait for the Railway or Vercel deploy to go green, then:

```bash
curl -s -o /dev/null -w "%{http_code}" https://api.premiers.gg/health
curl -s https://api.premiers.gg/api/orgs | head -c 300
```

Confirm the new columns or fields actually appear in the payload — this is how you prove a
migration applied without database access. Then check `environment-status` for production
and read the deploy logs for the migration lines.

Only after the API is verified do you merge the web promotion.

## Step 6 — close the loop

- Close the issues the promoted PRs resolved. `Closes #N` does **not** fire here.
- Update `premiers-web/docs/PLATFORM_STATE.md` §0 with the new production state.
- Note in the release PR what remains unreleased, if anything.

## Refusals

If asked to promote while CI is red, while production is ahead of staging, or while a
non-idempotent migration is in the diff, explain the specific problem and stop. Do not
force-push, do not rewrite history, and do not merge a promotion PR the user has not seen.
