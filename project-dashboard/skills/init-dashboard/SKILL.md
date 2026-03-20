---
name: init-dashboard
description: "Set up project dashboards — creates HTML templates, configures .dashboard.json, and reports what was created. Run this after enabling the project-dashboard plugin."
---

# Initialize Project Dashboards

You are setting up the project-dashboard system for this project.

## Steps

### 1. Check for existing config

Read `.dashboard.json` from the project root. If it exists, you're in update mode — confirm with the user before overwriting.

### 2. Detect project info

- **Project name**: Check `package.json` (`name`), `pyproject.toml` (`[project] name`), `Cargo.toml` (`[package] name`), or fall back to the current directory name
- **Repo URL**: Run `git remote get-url origin`, convert SSH to HTTPS:
  ```bash
  git remote get-url origin | sed -E 's|^git@([^:]+):|https://\1/|; s|\.git$||'
  ```

Present the detected values and ask the user to confirm or override:
- Project name
- Project description (ask for this — can't auto-detect)
- Repo URL
- Dashboard directory (default: `docs/dashboard`)
- Which dashboards to create (default: all 3: changelog, backlog, documentation)

### 3. Create dashboards

For each selected dashboard:

1. Create the dashboard directory if it doesn't exist: `mkdir -p {dashboard_dir}`
2. Read the template from `${CLAUDE_PLUGIN_ROOT}/templates/{name}.html`
3. Replace all `{{VARIABLE}}` placeholders:
   - `{{PROJECT_NAME}}` → detected/confirmed project name
   - `{{REPO_URL}}` → detected/confirmed repo URL
   - `{{DASHBOARD_DIR}}` → confirmed dashboard directory
   - `{{PROJECT_DESCRIPTION}}` → user-provided description
4. Write the populated template to `{dashboard_dir}/{name}.html`

### 4. Write config

Write `.dashboard.json` to the project root:

```json
{
  "project_name": "{PROJECT_NAME}",
  "repo_url": "{REPO_URL}",
  "dashboard_dir": "{DASHBOARD_DIR}",
  "dashboards": ["changelog", "backlog", "documentation"]
}
```

### 5. Report

Tell the user what was created:

```
Dashboard setup complete!

Created:
  {dashboard_dir}/changelog.html
  {dashboard_dir}/backlog.html
  {dashboard_dir}/documentation.html
  .dashboard.json

The post-commit hook will automatically trigger changelog and backlog updates after each git commit.

To manually update documentation, ask me to run the update-documentation agent.
```
