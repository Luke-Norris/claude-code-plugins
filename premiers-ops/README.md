# premiers-ops

Operating skills for the [Premiers](https://premiers.gg) platform — an org-neutral
competitive Zero Build Fortnite host built across `premiers-api`, `premiers-web` and
`premiers-discord-bot`.

These encode runbooks that were previously carried in one person's head or rediscovered by
re-reading the codebase every session: which repo promotes first, which alerts are real, how
to verify an issue before closing it, and where the truth about the platform actually lives.

## Skills

| Skill | Use it when |
|---|---|
| `premiers-status` | You want the honest state of the project, or to refresh `PLATFORM_STATE.md` §0 |
| `premiers-monitor` | You want to know whether anything is broken — Railway, Vercel, Postgres, endpoints |
| `premiers-release` | You are promoting `staging` to `production`, or checking whether that is safe |
| `premiers-triage` | You are deciding what to work on, filing a wave of issues, or cleaning the board |

Shared facts live in [`references/platform.md`](references/platform.md) — Railway service
IDs, endpoints, branch model, baselines, and the constraints that must never be violated.
Fix a wrong fact there, not in the individual skills.

## Why these have opinions

Three of these skills exist because of specific incidents:

- **`premiers-release` enforces api-before-web.** The web appends `T00:00:00` to a `date`
  field that the older API serialises as a full ISO instant, so promoting the web first
  renders blank event dates across every org page.
- **`premiers-triage` refuses to close an issue on a summary.** An automated triage pass
  flagged fourteen issues as stale; at least one was a real unbuilt feature. Verification
  against `file:line` is now mandatory.
- **`premiers-monitor` teaches the scanner baseline.** Production 4xx volume is dominated by
  internet scanners probing WordPress and credential paths. Reading it as a product incident
  wastes a morning.

## Install

```json
{
  "enabledPlugins": {
    "premiers-ops@Luke-Norris/claude-code-plugins": true
  }
}
```

## Constraints these skills protect

Premiers operates under Epic's Event License Terms, so competition entry and viewing can
never be gated behind payment, and a partner agreement can never restrict where a player
competes. The Discord bot holds no database access and no privileged intents. Every schema
change is an additive, idempotent, numbered migration. The skills will refuse work that
breaks these rather than quietly doing it.
