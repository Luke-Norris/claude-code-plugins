#!/bin/bash
# Stop hook for project-dashboard plugin
# Fires when Claude finishes responding. If files changed this turn (dirty flag
# set by dashboard-dirty.sh), it blocks the stop and tells Claude to dispatch the
# dashboard update agents. Loop-guarded via stop_hook_active.
INPUT=$(cat)
DIRTY=".claude/.dashboard-dirty"

# Find a Python interpreter (try python3, python3.12, python in order)
PYTHON=""
for cmd in python3 python3.12 python; do
    if command -v "$cmd" >/dev/null 2>&1; then
        PYTHON="$cmd"
        break
    fi
done

if [ -z "$PYTHON" ]; then
    exit 0
fi

# Parse stop_hook_active from the Stop hook JSON.
STOP_ACTIVE=$(echo "$INPUT" | "$PYTHON" -c "import sys,json; d=json.load(sys.stdin); print('1' if d.get('stop_hook_active') else '0')" 2>/dev/null)

# Loop guard: this stop is the continuation after we already dispatched the
# update agents. Their own edits re-set the dirty flag — clear it and exit so we
# don't loop forever.
if [ "$STOP_ACTIVE" = "1" ]; then
    rm -f "$DIRTY" 2>/dev/null
    exit 0
fi

# Stay inert outside dashboard projects.
if [ ! -f ".dashboard.json" ]; then
    exit 0
fi

# Nothing changed this turn — don't waste tokens refreshing the dashboards.
if [ ! -f "$DIRTY" ]; then
    exit 0
fi

# Files changed: block the stop and ask Claude to refresh the dashboards.
"$PYTHON" -c "import json; print(json.dumps({'decision':'block','reason':'Files changed this session. Dispatch the project-dashboard update agents now to refresh docs/dashboard/*.html:\n1. update-changelog — record what changed this session\n2. update-backlog — update/close any items this work resolved or surfaced\n3. update-documentation — reflect any API/architecture/config changes\nIf a given dashboard has nothing new, that agent should no-op.'}))"
exit 0
