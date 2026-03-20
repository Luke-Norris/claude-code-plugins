---
name: update-changelog
description: "Updates the project changelog HTML with latest git commits and task status changes. Use after completing features, fixing bugs, or finishing a development session."
model: sonnet
color: green
---

# Update Changelog Agent

You update the project's changelog dashboard with the latest changes.

## Setup

1. **Read `.dashboard.json`** from the project root to get:
   - `dashboard_dir` — where HTML files live (default: `docs/dashboard`)
   - `repo_url` — for commit hyperlinks
   - `project_name` — for display
2. The changelog file is at `{dashboard_dir}/changelog.html`

## Steps

1. **Read current state**: Read the changelog HTML to understand current content and last update date.

2. **Gather new data**:
   - Run `git log --oneline --since="LAST_UPDATE_DATE"` to find new commits
   - Read the backlog HTML for current task status changes

3. **Categorize commits** by type:
   - `feat` = new features → `.tag-feat`
   - `fix` = bug fixes → `.tag-fix`
   - `refactor` = code restructuring → `.tag-refactor`
   - `docs` = documentation → `.tag-docs`
   - `test` = testing → `.tag-test`
   - `chore` = maintenance → `.tag-chore`

4. **Update the HTML**:
   - Add new commits to the appropriate session or create a new one
   - Update the "Current Tasking" section with any status changes
   - Update the date in the header

5. **Maintain the design system**: All new HTML must use existing CSS classes:
   - Phases: `.phase`, `.phase-header`, `.badge-done`, `.badge-active`, `.badge-planned`
   - Commits: `.hash`, `.tag`, `.tag-feat`, `.tag-fix`, `.tag-chore`, `.tag-refactor`, `.tag-docs`, `.tag-test`
   - Tasks: `.task-card`, `.pri-critical`, `.pri-high`, `.pri-medium`, `.status-dot`, `.dot-open`, `.dot-done`, `.dot-active`

## Important
- Never remove existing changelog entries — only add new ones
- Update the header date to today's date
- If no new changes are found, report that and don't modify the file

## Layout Rules

The changelog uses a two-column layout with a session sidebar.

- **Commit hashes** must be hyperlinked:
  ```html
  <a href="{REPO_URL}/commit/{full_hash}" class="hash" target="_blank" rel="noopener">{short_hash}</a>
  ```
  Read `REPO_URL` from `.dashboard.json`. Get full hashes with `git rev-parse {short_hash}`.

- **New sessions** prepend to the top of `<div class="changelog-content" id="changelog-content">` (reverse chronological — newest first)

- **Session anchors**: each session div must have `id="session-{date}{suffix}"`. First session of the day = no suffix, second = `b`, etc.

- **Sidebar entry**: add a corresponding `<a>` at the top of `<nav class="changelog-sidebar">` (after the `<h3>`):
  ```html
  <a class="sidebar-session" href="#session-YYYY-MM-DD">
    <span class="sidebar-date">Mon DD</span>
    <span class="sidebar-title">Session Title</span>
  </a>
  ```

- **Test results**: use `.test-ref-card` reference style linking to `test-results.html`. Never inline test result tables.

- When the post-commit hook fires, it provides full hash, short hash, message, and URL in its output. Use these values directly.
