# Claude Code Plugins

A collection of reusable Claude Code plugins.

## Available Plugins

### [project-dashboard](./project-dashboard/)

Auto-maintained HTML dashboards for project changelog, backlog, documentation, and test results. Includes agents that auto-update after commits and an `/init-dashboard` skill to scaffold dashboards into any project.

## Usage

Enable a plugin in your project's `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "project-dashboard@Luke-Norris/claude-code-plugins": true
  }
}
```
