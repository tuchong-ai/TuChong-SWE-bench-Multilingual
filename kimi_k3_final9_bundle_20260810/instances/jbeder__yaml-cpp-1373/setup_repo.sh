#!/bin/bash
set -e
# prep_script for jbeder/yaml-cpp (cpp)

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
    git remote add origin https://github.com/jbeder/yaml-cpp.git
fi
git config http.version HTTP/1.1
# checkout only the pre-fix base; never fetch the default-branch tip
claudedata_git_retry git fetch --depth 1 origin 1bff0699f867722024558253f4d8b54b51107471 2>/dev/null || claudedata_git_retry git fetch origin 1bff0699f867722024558253f4d8b54b51107471
git checkout --detach 1bff0699f867722024558253f4d8b54b51107471

# Remove future refs and objects before the agent can inspect the workspace.
git remote remove origin 2>/dev/null || true
git for-each-ref --format='delete %(refname)' | git update-ref --stdin
git reflog expire --expire=now --all
rm -f .git/FETCH_HEAD .git/ORIG_HEAD
if [ -f .git/shallow ]; then grep -vxF 29a6f43950ce22be9f90ea1071e94bcb675c8c51 .git/shallow > .git/shallow.clean || true; if [ -s .git/shallow.clean ]; then mv .git/shallow.clean .git/shallow; else rm -f .git/shallow.clean .git/shallow; fi; fi
git gc --prune=now --quiet
if git cat-file -e 29a6f43950ce22be9f90ea1071e94bcb675c8c51^{commit} 2>/dev/null; then
    echo 'future fix commit remains readable after history scrub' >&2
    exit 1
fi
