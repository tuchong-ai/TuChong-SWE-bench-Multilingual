# jhy__jsoup-2483

## Overview

| Field | Value |
|---|---|
| Repository | [jhy/jsoup](https://github.com/jhy/jsoup) |
| Language | java |
| License | MIT |
| Version | `java-e1b0df5fec53` |
| Base Commit | `e1b0df5fec53` |
| Fix Commit | `823709f51999` |
| Fix Date | 2026-04-05 |
| Issue | [link](https://github.com/jhy/jsoup/issues/2483) |
| PR | N/A |
| Contamination Level | low |
| Training Value Score | 7.0 |
| Training Verdict | medium |

## Problem Statement

Small HTML documents can fail when parsed through jsoup streaming APIs if the document charset must be discovered from the content. In this case, Connection.Response.streamParser() and DataUtil.streamParser(Path, ...) should complete successfully and produce the same correctly decoded document behavior as regular parsing. Instead, streamParser().complete() can throw ValidationException: Object must not be null. Larger documents do not show the failure. Regular parse behavior and existing stream parsing behavior for other inputs must remain unchanged.

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 2 |
| PASS_TO_PASS tests | 105 |
| Gold F2P count | 2 |
| Gold P2P count | 105 |
| Agent F2P passed | 2 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 3 | 69 |
| model_patch.patch (LLM output) | 1 | 20 |
| test_patch.patch (test changes) | 2 | 66 |

## FAIL_TO_PASS Tests

- `org.jsoup.helper.DataUtilTest#streamParserWorksWhenCharsetDetectionFullyReadsFile`
- `org.jsoup.integration.ConnectTest#bufferedStreamParserWorksWhenCharsetDetectionFullyReadsResponse`

## Test Command

```bash
__maven_rc=0; mvn clean test -Dtest=DataUtilTest,ConnectTest || __maven_rc=$?; find . -path '*/target/surefire-reports/TEST-*.xml' -type f -exec cat {} \; 2>/dev/null; [ "$__maven_rc" -eq 0 ]
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
docker build -t swe-jhy__jsoup-2483 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-jhy__jsoup-2483 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
