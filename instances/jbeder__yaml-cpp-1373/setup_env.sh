#!/usr/bin/env bash
set -e

cmake -S . -B build -DYAML_CPP_BUILD_TESTS=ON -DCMAKE_CXX_FLAGS=-Wno-error=maybe-uninitialized && cmake --build build -j2

__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete

# SWE-bench boundary: hide PR tests and baseline output from the agent.
__claudedata_repo_root="$(git rev-parse --show-toplevel)"
cd "$__claudedata_repo_root"
if git cat-file -e HEAD:test/integration/load_node_test.cpp 2>/dev/null; then
    git checkout HEAD -- test/integration/load_node_test.cpp
else
    rm -f -- test/integration/load_node_test.cpp
fi
find "$__claudedata_repo_root" -type f -name __baseline__.txt -delete
# Remove test-runner artifacts that can retain held-out test names or bytecode.
find . -type d \( -name __pycache__ -o -name .pytest_cache -o -name .hypothesis \) -prune -exec rm -rf -- {} +
find . -type f \( -name '*.pyc' -o -name '*.pyo' -o -name '.coverage' -o -name '.coverage.*' \) -delete
rm -rf -- /tmp/pytest-of-* /tmp/pytest-* /tmp/hypothesis-* 2>/dev/null || true
rm -f __baseline__.txt
echo 'workspace ready'