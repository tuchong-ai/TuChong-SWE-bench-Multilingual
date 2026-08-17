# gin-gonic__gin-4622

## Overview

| Field | Value |
|---|---|
| Repository | [gin-gonic/gin](https://github.com/gin-gonic/gin) |
| Language | go |
| License | MIT |
| Version | `go-da1e108614ec` |
| Base Commit | `da1e108614ec` |
| Fix Commit | `d9307dbcbbe7` |
| Fix Date | 2026-06-22 |
| Issue | [link](https://github.com/gin-gonic/gin/issues/4622) |
| PR | [link](https://github.com/gin-gonic/gin/pull/4702) |
| Contamination Level | low |
| Training Value Score | 6.0 |
| Training Verdict | medium |

## Problem Statement

## Description

After upgrading from v1.10.1 to v1.12.0, `Context.SaveUploadedFile` started to fail when saving files directly into existing system directories like `/tmp`.

The failure happens due to an attempt to call `os.Chmod` on the target directory, even if it already exists and is not owned by the process.

Relevant code:
https://github.com/gin-gonic/gin/blob/v1.12.0/context.go#L734

## Reproduction

```go
file, _ := c.FormFile("file")

// Saving directly into /tmp
err := c.SaveUploadedFile(file, "/tmp/test.txt")
if err != nil {
  panic(err)
}
```

## Actual behavior

The call fails with:

chmod /tmp: operation not permitted

## Expected behavior

If the directory already exists, especially for system directories like `/tmp`, `SaveUploadedFile` should not attempt to modify its permissions.

The previous behavior (v1.10.1) only used `os.MkdirAll`, which does not change permissions on existing directories.

## Impact

This is a breaking change for common usage patterns such as:

* saving files to `/tmp/<filename>`
* writing into pre-existing directories managed by the OS or container runtime

## Context

This behavior appears to be introduced together with the change that allows specifying permissions for created directories (see #4068). However, applying `chmod` unconditionally also affects already existing directories.

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 1 |
| PASS_TO_PASS tests | 3 |
| Gold F2P count | 1 |
| Gold P2P count | 3 |
| Agent F2P passed | 1 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 1 | 37 |
| model_patch.patch (LLM output) | 1 | 24 |
| test_patch.patch (test changes) | 1 | 54 |

## FAIL_TO_PASS Tests

- `TestSaveUploadedFileToExistingDir`

## Test Command

```bash
export PATH=/opt/go-1.25.7/bin:$PATH; export GOTOOLCHAIN=local; __go_filter="$(python3 -c 'import re
import subprocess
import sys

test_re = re.compile(r"^\s*func\s+((?:Test|Fuzz|Example)[A-Za-z0-9_]*)\s*\(")
names = []
for path in sys.argv[1:]:
    with open(path, encoding="utf-8") as handle:
        lines = handle.read().splitlines()
    changed = set()
    new_line = 0
    diff = subprocess.check_output(
        ["git", "diff", "--unified=0", "--", path], text=True
    )
    for line in diff.splitlines():
        hunk = re.match(r"@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@", line)
        if hunk:
            new_line = int(hunk.group(1)) - 1
        elif line.startswith("+") and not line.startswith("+++"):
            new_line += 1
            changed.add(new_line)
        elif line.startswith(" "):
            new_line += 1
    current = ""
    guards = 0
    for number, line in enumerate(lines, 1):
        match = test_re.match(line)
        if match:
            current = match.group(1)
            if guards < 2:
                names.append(current)
                guards += 1
        if number in changed and current:
            names.append(current)
print("^(" + "|".join(dict.fromkeys(names)) + ")$")' context_test.go)"; [ "$__go_filter" != "^()$" ] && go test -v -count=1 -run "$__go_filter" .
```

## Files

| File | Description |
|---|---|
| `Dockerfile` | Docker build template for the test environment |
| `setup_repo.sh` | Clones the repository at base commit |
| `setup_env.sh` | Compiles project and prepares test environment |
| `run_tests.sh` | Runs the regression test command |
| `base_commit.txt` | Base commit SHA (pre-fix state) |
| `gold_patch.patch` | Upstream fix diff (ground truth) |
| `test_patch.patch` | Test file changes for FAIL_TO_PASS verification |
| `model_patch.patch` | Agent-generated code diff (LLM solution) |
| `UPSTREAM_LICENSE.txt` | Upstream repository license (MIT) |
| `task.jsonl` | Complete task definition with all SWE-bench fields |
| `environment.json` | Environment config (test_command, F2P/P2P, grading logs) |
| `model_input.json` | Model input prompt |
| `trajectory.canonical.jsonl` | Canonical trajectory (tool calls + reasoning chain) |
| `trajectory.full.jsonl` | Full API call-level trajectory (all raw records) |

## Verification

```bash
# 1. Build the Docker environment
docker build -t swe-gin-gonic__gin-4622 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-gin-gonic__gin-4622 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
