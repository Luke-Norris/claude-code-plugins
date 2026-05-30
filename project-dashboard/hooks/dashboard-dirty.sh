#!/bin/bash
# Dirty-flag hook for project-dashboard plugin
# Fires on PostToolUse(Write|Edit|NotebookEdit) — marks the session as having
# changed files, so the Stop hook knows to refresh the dashboards.
# No-op in projects without a .dashboard.json (plugin stays inert elsewhere).

# Only act in dashboard projects (cwd is the project root for hook execution).
if [ -f ".dashboard.json" ]; then
    mkdir -p ".claude" 2>/dev/null
    touch ".claude/.dashboard-dirty" 2>/dev/null
fi

exit 0
