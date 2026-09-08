# Premiers platform reference

Shared facts for every `premiers-ops` skill. Verified 2026-09-08. When something here
turns out to be wrong, fix it here rather than in the individual skills.

## Repos

| Repo | Path | Role | Deploy |
|---|---|---|---|
| `premiers-api` | `Z:\dev\default\premiers-api` | Node/Express/Postgres REST backend; **sole authority for the schema** | Railway → api.premiers.gg |
| `premiers-web` | `Z:\dev\default\premiers-web` | React 19 + Vite SPA | Vercel → premiers.gg |
| `premiers-discord-bot` | `Z:\dev\default\premiers-discord-bot` | discord.js v14 thin client over the API; **no database access, ever** | Railway |
| `premiers-overlay` | `Z:\dev\default\premiers-overlay` | Rust axum engine + C# replay sidecar | — |
| `premiers-desktop` | `Z:\dev\default\premiers-desktop` | Tauri v2 scaffold | — |

## Branch model

Every repo uses `production` (live) + `staging`. Feature branches PR into **`staging`**;
promotion is a `staging` → `production` PR. Docs/CI-only changes may land on `production`
directly, then back-merge to `staging` immediately.

**`Closes #N` does not auto-close** — the default branch is `production` and feature PRs
target `staging`, so close issues by hand after merging.

Fresh branch per change, never reuse a merged branch.

## Railway

The project is named `premiers` and holds three services — `premiers-api`,
`premiers-discord-bot` and `Postgres` — across a `production` and a `staging` environment.

**Resolve every id at runtime; none are written down here.** Call `list-projects`, then
`list-services` with the project id, and match on those names. Ids are stable, so resolve
them once at the start of a task and reuse them for its duration.

Load the connector tools in one call:

```
ToolSearch "select:mcp__b56536f5-7313-41f4-9e36-265db65b4d15__environment-status,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__list-deployments,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__http-error-rate,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__http-requests,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__get-service-metrics,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__get-logs,mcp__b56536f5-7313-41f4-9e36-265db65b4d15__list-variables"
```

The connector UUID can change between sessions. If those exact names fail, search
`ToolSearch "railway status logs metrics"` and use what comes back.

**Never** use `railway ssh` or register SSH keys — a 2026-08-14 incident established that
Railway work goes through the connector only. Never print variable **values**; names only.

## Vercel

Project `lukenorris-projects/premiers`. The MCP connector may be unauthorized; the **CLI
works** from `Z:\dev\default\premiers-web`: `vercel ls`, `vercel ls --prod`, `vercel env ls`
(names only), `vercel domains ls`. `productionBranch` is `production`.

## Public endpoints

| URL | Expect |
|---|---|
| `https://api.premiers.gg/health` | 200 |
| `https://premiers.gg` | 200 |
| `https://premiers-api-staging.up.railway.app/health` | 200 |

Unauthenticated reads useful for smoke tests: `/api/config`, `/api/leagues`, `/api/orgs`,
`/api/tournaments`, `/api/creative/maps`, `/api/orgs/:slug/events`.

## Baselines

Pre-launch traffic is low, and most 4xx volume is **internet scanners** probing WordPress and
credential paths rather than anything the product did. Establish the current baseline from
the connector at the start of a session rather than assuming a figure from this file; what
matters is the shape (5xx is always real, 4xx usually is not) rather than a number that ages.

Resource use is small and steady. Treat a sudden change in memory or database disk as the
signal, not the absolute value.

**Known operational gaps** are tracked as issues on the board under the `ops` label rather
than enumerated here. Check the board for the current list before reporting on them — several
are being closed in the run-up to the 2026-10-09 release, and a stale list here would send an
agent chasing something already fixed.

One caveat worth carrying: a claim that the API runs a particular Node version should be
**measured** (read `process.versions.node` from a health endpoint) rather than inferred from
build logs. The declared builder in `railway.toml` and the builder actually in use have
diverged before, which makes build-log inference unreliable.

## Source of truth

- **State:** `premiers-web/docs/PLATFORM_STATE.md` — **start at §0**. §1–§6 are a 2026-07-24
  snapshot that has drifted; §0 is authoritative over them.
- **Rulings:** `Z:\dev\default\DECISIONS.md` (D1–D11). Rulings are records; never rewrite one.
- **Todos:** GitHub Project **"Premiers Platform"** (`gh project … 1 --owner Luke-Norris`,
  id `PVT_kwHOAzEr-M4Bc7fL`). Fields: Status (Todo / In Progress / Done), Priority (Now /
  Next / Later), Workstream (Go-live / Brand / Backend / Payments / Overlay / Desktop / Bot /
  Polish). New issues do **not** auto-add — `ADD_TO_PROJECT_PAT` is unset (web#68).
- Labels spanning repos: `partner-program`, `revenue`, `compliance`, `ops`, `launch-critical`,
  plus the older `area:*` set.

## The partner-org release — 2026-10-09

Partner orgs host their events on Premiers-owned maps, through the Premiers system, from
their own Discord servers, in exchange for brand exposure. Rulings are **D11**:

1. Premiers-owned UEFN islands are being built; the map registry must be empty-safe.
2. Sign-in becomes an **allowlist** — the Premiers guild or any guild bound to an approved
   partner org — still fail-closed.
3. The queue stays **global**. Per-guild pools were rejected: orgs are ~10 people. The design
   problem is the match *room*, not the pool.
4. Premium consolidates into **one new entitlements table** (players and orgs, with grant
   source and expiry), closing api#161.

## Hard constraints that must never be violated

- **Epic Event License Terms 2(a)(ii):** never gate or advantage participation in, or
  viewing of, competition behind any payment. The free floor is a legal requirement.
- **ELT 3(i):** a partner agreement may bind the org's hosting; it may **never** restrict a
  player from competing anywhere else, including Epic's own events.
- **ELT 2(a)(xv):** never supply match data to betting or fantasy businesses.
- **Epic Developer Rules 3.4.1 / 1.12 / 4.1:** contests happen entirely outside islands; no
  links or CTAs in an island or its metadata; never reward island playtime.
- No entry fees, rake, peer-to-peer staking, purchasable currency or sweepstakes.
- **Discord:** non-privileged intents only (Guilds + GuildVoiceStates). Never request
  GUILD_MEMBERS, GUILD_PRESENCES or MESSAGE_CONTENT. DMs are opt-in.
- The bot never gets database access.
- New SQL is a new numbered migration, **additive and idempotent** (shared Postgres).
