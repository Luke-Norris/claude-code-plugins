---
name: premiers-monitor
description: >
  Check the health of the Premiers stack — Railway services, Postgres, Vercel, public
  endpoints, deploys, traffic and errors. Use when the user asks whether the site or API is
  up, whether anything is broken, what the error rate looks like, why something is slow or
  failing, or asks for a health check, status check or ops digest.
---

# Check Premiers stack health

Read-only. **Never** deploy, restart, redeploy, set a variable or change configuration while
running this skill. Report problems; act on them only if the user then asks.

Read `references/platform.md` for IDs, endpoints and baselines.

## What to check

Load the Railway connector tools in one `ToolSearch` call (the select string is in the
reference file), then:

1. **`environment-status`** for production and staging, `includeSuccessful: true`. Flag any
   service not online, any crash, any replica count other than 1, and any warning.
2. **`list-deployments`** over the window. Any `FAILED` or `CRASHED` is an alert.
3. **`http-error-rate`** and **`http-requests`** for premiers-api in production. **Any 5xx is
   an alert.** 4xx volume usually is not — see the scanner baseline in the reference. Before
   reporting a 4xx spike, pull `get-logs` with `types: ["http"]` and look at the paths and
   user agents. Requests for `/wp-login.php`, `/.env`, `/.git/config` and similar are
   scanners; report them as noise, not as an incident.
4. **`get-service-metrics`** — Postgres `DISK_USAGE_GB`, api `MEMORY_USAGE_GB`. Compare to
   the baselines and flag material growth, not noise.
5. **Public endpoints** — curl each URL in the reference with
   `-o /dev/null -w "%{http_code} %{time_total}s"`. Anything other than 200 is an alert.
6. **Vercel** — `vercel ls --prod` from the web repo. Report the production deployment's age.
7. **Deploy logs** — `get-logs` on the most recent deployment when anything above looks off.

## Things that look like incidents but are not

- **High 4xx with near-zero 2xx.** Almost always scanners. Check paths first.
- **An empty deploy log stream.** The API has no request logger, so an idle service legitimately
  produces no output. This is a known gap, not evidence of a dead process.
- **Postgres restarting at a weekend.** Auto-updates run Saturday 10:00 through Sunday 18:00
  UTC. Expected, though worth flagging if it lands near a release.

## Things that are real and easy to miss

- The production Postgres security-patch warning, unresolved since 2026-08-20.
- The API running Node 18 while dependencies want ≥20.
- A production deployment noticeably older than the current `production` branch head — that
  means a deploy silently failed to trigger. Compare `git rev-parse origin/production` with
  the deployment's commit.

## Output

Lead with a one-line verdict: all green, or the single most important problem. Then alerts,
each with what you saw and what it implies. Then numbers, but only those that changed
meaningfully. Keep it short when everything is fine; do not pad a healthy report.

If a tool or credential fails, say which one failed rather than silently dropping that
section — a missing check reported as "fine" is worse than no check.
