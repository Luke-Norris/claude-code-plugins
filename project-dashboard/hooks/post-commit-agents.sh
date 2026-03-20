#!/bin/bash
# Post-commit hook for project-dashboard plugin
# Fires on PostToolUse(Bash) — detects git commits and tells Claude to dispatch dashboard agents.
INPUT=$(cat)

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

# Parse command from PostToolUse JSON
COMMAND=$(echo "$INPUT" | "$PYTHON" -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# Only fire on actual git commit (anchored match, exclude amend/dry-run)
if [[ "$COMMAND" =~ ^git\ commit ]] \
   && [[ ! "$COMMAND" =~ --dry-run ]] \
   && [[ ! "$COMMAND" =~ --amend ]]; then

    # Read config from .dashboard.json if it exists
    REPO_URL=""
    if [ -f ".dashboard.json" ] && [ -n "$PYTHON" ]; then
        REPO_URL=$("$PYTHON" -c "import json; d=json.load(open('.dashboard.json')); print(d.get('repo_url',''))" 2>/dev/null)
    fi

    # Fallback: detect from git remote
    if [ -z "$REPO_URL" ]; then
        REMOTE_URL=$(git remote get-url origin 2>/dev/null)
        # Convert SSH to HTTPS
        REPO_URL=$(echo "$REMOTE_URL" | sed -E 's|^git@([^:]+):|https://\1/|; s|\.git$||')
    fi

    if [ -z "$REPO_URL" ]; then
        exit 0
    fi

    FULL_HASH=$(git log -1 --format="%H")
    SHORT_HASH=$(git log -1 --format="%h")
    MESSAGE=$(git log -1 --format="%s")
    COMMIT_URL="${REPO_URL}/commit/${FULL_HASH}"

    cat <<EOF
Git commit detected:
  Hash: ${SHORT_HASH} (${FULL_HASH})
  Message: ${MESSAGE}
  URL: ${COMMIT_URL}

Please dispatch these agents now:
1. update-changelog — add this commit with hash hyperlinked as <a href="${COMMIT_URL}" class="hash">${SHORT_HASH}</a>
2. update-backlog — check if this commit resolves any open items, update status accordingly
EOF
    exit 0
fi

exit 0
