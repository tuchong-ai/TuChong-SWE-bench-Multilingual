#!/bin/bash
set -e
# prep_script for typescript-eslint/typescript-eslint (ts)

claudedata_git_retry() {
    local attempt=1
    until "$@"; do
        if [ "$attempt" -ge 3 ]; then return 1; fi
        sleep "$((attempt * 2))"
        attempt=$((attempt + 1))
    done
}
if [ ! -d .git ]; then
    git init .
    git remote add origin https://github.com/typescript-eslint/typescript-eslint.git
fi
git config http.version HTTP/1.1
# checkout only the pre-fix base; never fetch the default-branch tip
claudedata_git_retry git fetch --depth 1 origin 4fa6acd4cfa70d32302e41a595ee39efff93b2c4 2>/dev/null || claudedata_git_retry git fetch origin 4fa6acd4cfa70d32302e41a595ee39efff93b2c4
git checkout --detach 4fa6acd4cfa70d32302e41a595ee39efff93b2c4

# Remove future refs and objects before the agent can inspect the workspace.
git remote remove origin 2>/dev/null || true
git for-each-ref --format='delete %(refname)' | git update-ref --stdin
git reflog expire --expire=now --all
rm -f .git/FETCH_HEAD .git/ORIG_HEAD
if [ -f .git/shallow ]; then grep -vxF c3f8ed5ddfa757d91911489105bf8b57a16404c9 .git/shallow > .git/shallow.clean || true; if [ -s .git/shallow.clean ]; then mv .git/shallow.clean .git/shallow; else rm -f .git/shallow.clean .git/shallow; fi; fi
git gc --prune=now --quiet
if git cat-file -e c3f8ed5ddfa757d91911489105bf8b57a16404c9^{commit} 2>/dev/null; then
    echo 'future fix commit remains readable after history scrub' >&2
    exit 1
fi
