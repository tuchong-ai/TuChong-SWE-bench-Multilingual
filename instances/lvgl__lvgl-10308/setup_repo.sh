#!/bin/bash
set -e
# prep_script for lvgl/lvgl (c)

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
    git remote add origin https://github.com/lvgl/lvgl.git
fi
git config http.version HTTP/1.1
# checkout only the pre-fix base; never fetch the default-branch tip
claudedata_git_retry git fetch --depth 1 origin 7da9cae8837c4598ab9ba0f0cd0cf6901c92595e 2>/dev/null || claudedata_git_retry git fetch origin 7da9cae8837c4598ab9ba0f0cd0cf6901c92595e
git checkout --detach 7da9cae8837c4598ab9ba0f0cd0cf6901c92595e

# Remove future refs and objects before the agent can inspect the workspace.
git remote remove origin 2>/dev/null || true
git for-each-ref --format='delete %(refname)' | git update-ref --stdin
git reflog expire --expire=now --all
rm -f .git/FETCH_HEAD .git/ORIG_HEAD
if [ -f .git/shallow ]; then grep -vxF 8274446cecf5135e86d8dfe18f5c02d020715d63 .git/shallow > .git/shallow.clean || true; if [ -s .git/shallow.clean ]; then mv .git/shallow.clean .git/shallow; else rm -f .git/shallow.clean .git/shallow; fi; fi
git gc --prune=now --quiet
if git cat-file -e 8274446cecf5135e86d8dfe18f5c02d020715d63^{commit} 2>/dev/null; then
    echo 'future fix commit remains readable after history scrub' >&2
    exit 1
fi
