---
name: premiers-triage
description: >
  Triage Premiers issues and keep the project board honest — classify open issues, find work
  that has no issue, close what is genuinely done, and reconcile the board. Use when the user
  asks what to work on next, what is left before the release, to clean up the backlog, to
  check the board, or to file issues for a wave of work.
---

# Triage Premiers issues and the board

Read `references/platform.md` for the board id, label vocabulary and branch conventions.

## The rule that matters most

**Never close an issue on a summary. Verify it against code first.**

An automated triage pass on 2026-09-08 flagged fourteen issues as stale. At least one
(api#11, the PvP duel feature) was a real unbuilt feature that would have been wrongly
closed. The cost of a wrong close is Luke losing backlog he cannot recover from memory; the
cost of leaving one open is trivial. When you cannot verify, leave it open and say why.

To verify: read the issue body, then grep for the thing it claims is missing. If the issue
says an endpoint does not exist, look for the route. If it says a column is unserved, read
the handler's SELECT. Quote the `file:line` in the closing comment.

## Classify against the release

Buckets, in priority order:

1. **launch-critical** — blocks partner orgs hosting on Premiers maps from their own guilds
   by 2026-10-09.
2. **launch-should** — materially improves that launch.
3. **revenue / compliance / ops** — real work, not launch-gating.
4. **hygiene** — polish.
5. **stale** — built or overtaken. Verify, then close with evidence.

Also estimate size (S under a day, M one to three days, L more) and owner: `agent` for work
an agent can finish alone, `luke` for anything needing a console, a credential, a payment
method or a product ruling, `both` where an agent prepares and Luke approves.

## Find the work that has no issue

The gaps are usually larger than the backlog. Cross-check the release requirements against
open issues and list what nobody has filed. On 2026-09-08 that included multi-guild bot
operation, the map-lock policy, the partner agreement, the staging promotion, alerting and
bot CI — none of which had an issue.

## Reconcile the board

```bash
gh issue list --repo Luke-Norris/<repo> --state open --limit 200 --json number,title,url
gh project item-list 1 --owner Luke-Norris --limit 300 --format json
gh project item-add 1 --owner Luke-Norris --url <issue url>
```

Check for: open issues absent from the board, rows with no Priority or Workstream, and rows
whose Status contradicts the issue state (a closed issue still showing In Progress). New
issues do **not** auto-add while `ADD_TO_PROJECT_PAT` is unset, so expect drift.

## Filing issues

Body must carry acceptance criteria concrete enough that an agent can finish without asking
a question. Reference `file:line` for anything that already exists. Apply the cross-repo
labels plus the existing `area:*` ones. Add each new issue to the board by hand.

Write issue bodies and comments to a **file** and use `--body-file`. Passing them inline
through the shell mangles backticks and `${...}` sequences, which silently corrupts code
references.

## Recording rulings

When Luke decides something structural, record it in three places: a comment on the issue it
unblocks, a numbered decision in `Z:\dev\default\DECISIONS.md`, and — if it changes what is
true of the platform — `premiers-web/docs/PLATFORM_STATE.md` §0. Rulings in DECISIONS.md are
records; add new ones, never rewrite old ones.
