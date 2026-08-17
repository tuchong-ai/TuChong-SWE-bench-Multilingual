#!/usr/bin/env bash
set -e

export NX_NO_CLOUD=true NX_DAEMON=false; CLAUDEDATA_TOOL_BIN="${CLAUDEDATA_TOOL_BIN:-$HOME/.claudedata-bin}"; mkdir -p "$CLAUDEDATA_TOOL_BIN"; printf '%s\n' '#!/bin/sh' 'exec corepack pnpm "$@"' > "$CLAUDEDATA_TOOL_BIN/pnpm"; printf '%s\n' '#!/bin/sh' 'exec corepack yarn "$@"' > "$CLAUDEDATA_TOOL_BIN/yarn"; chmod +x "$CLAUDEDATA_TOOL_BIN/pnpm" "$CLAUDEDATA_TOOL_BIN/yarn"; export PATH="$CLAUDEDATA_TOOL_BIN:$PATH"; if [ -f pnpm-lock.yaml ]; then SKIP_POSTINSTALL=1 corepack pnpm install --frozen-lockfile; elif [ -f yarn.lock ]; then SKIP_POSTINSTALL=1 corepack yarn install --immutable; elif [ -f package-lock.json ]; then npm ci; else npm install; fi

__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete

# SWE-bench boundary: hide PR tests and baseline output from the agent.
__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
if git cat-file -e HEAD:packages/eslint-plugin/tests/rules/no-unused-vars/no-unused-vars.test.ts 2>/dev/null; then
    git checkout HEAD -- packages/eslint-plugin/tests/rules/no-unused-vars/no-unused-vars.test.ts
else
    rm -f -- packages/eslint-plugin/tests/rules/no-unused-vars/no-unused-vars.test.ts
fi
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete
# Remove test-runner artifacts that can retain held-out test names or bytecode.
find . -type d \( -name __pycache__ -o -name .pytest_cache -o -name .hypothesis \) -prune -exec rm -rf -- {} +
find . -type f \( -name '*.pyc' -o -name '*.pyo' -o -name '.coverage' -o -name '.coverage.*' \) -delete
rm -rf -- /tmp/pytest-of-* /tmp/pytest-* /tmp/hypothesis-* 2>/dev/null || true
rm -f __baseline__.txt
echo 'workspace ready'