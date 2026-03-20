# project-dashboard

Auto-maintained HTML dashboards for any project. Provides:

- **3 HTML dashboard templates**: changelog, backlog, documentation
- **3 auto-update agents**: triggered after commits or on demand
- **Post-commit hook**: auto-dispatches changelog + backlog agents after `git commit`
- **`/init-dashboard` skill**: interactive setup wizard

## Quick Start

1. Enable the plugin in your project's `.claude/settings.json`:
   ```json
   { "enabledPlugins": { "project-dashboard@Luke-Norris/claude-code-plugins": true } }
   ```
2. Run `/init-dashboard` to scaffold dashboards into your project
3. Commit as usual — the hook auto-triggers changelog and backlog updates

## Dashboards

| Dashboard | Description | Auto-updated |
|-----------|-------------|:---:|
| Changelog | Session sidebar, reverse-chron, commit hyperlinks | Yes (after commits) |
| Backlog | Filterable cards, stats scorecard | Yes (after commits) |
| Documentation | Sticky sidebar TOC, scroll-spy | Manual |

## Configuration

After running `/init-dashboard`, a `.dashboard.json` file is created in your project root:

```json
{
  "project_name": "MyProject",
  "repo_url": "https://github.com/user/repo",
  "dashboard_dir": "docs/dashboard",
  "dashboards": ["changelog", "backlog", "documentation"]
}
```

Agents and hooks read this file to find dashboard paths and repo URLs.
