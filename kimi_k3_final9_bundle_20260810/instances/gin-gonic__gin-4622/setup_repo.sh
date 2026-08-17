#!/bin/bash
set -e
# prep_script for gin-gonic/gin (go)

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
    git remote add origin https://github.com/gin-gonic/gin.git
fi
git config http.version HTTP/1.1
# checkout only the pre-fix base; never fetch the default-branch tip
claudedata_git_retry git fetch --depth 1 origin da1e108614ecbbadfa5736b1b297b16121d23b9b 2>/dev/null || claudedata_git_retry git fetch origin da1e108614ecbbadfa5736b1b297b16121d23b9b
git checkout --detach da1e108614ecbbadfa5736b1b297b16121d23b9b

# Remove future refs and objects before the agent can inspect the workspace.
git remote remove origin 2>/dev/null || true
git for-each-ref --format='delete %(refname)' | git update-ref --stdin
git reflog expire --expire=now --all
rm -f .git/FETCH_HEAD .git/ORIG_HEAD
if [ -f .git/shallow ]; then grep -vxF d9307dbcbbe796a64d9e0ef23452da888dd7f904 .git/shallow > .git/shallow.clean || true; if [ -s .git/shallow.clean ]; then mv .git/shallow.clean .git/shallow; else rm -f .git/shallow.clean .git/shallow; fi; fi
git gc --prune=now --quiet
if git cat-file -e d9307dbcbbe796a64d9e0ef23452da888dd7f904^{commit} 2>/dev/null; then
    echo 'future fix commit remains readable after history scrub' >&2
    exit 1
fi
