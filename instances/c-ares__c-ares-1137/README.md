# c-ares__c-ares-1137

## Overview

| Field | Value |
|---|---|
| Repository | [c-ares/c-ares](https://github.com/c-ares/c-ares) |
| Language | c |
| License | MIT |
| Version | `c-17dbbbd4fdbf` |
| Base Commit | `17dbbbd4fdbf` |
| Fix Commit | `a756d32587fa` |
| Fix Date | 2026-07-03 |
| Issue | [link](https://github.com/c-ares/c-ares/issues/1137) |
| PR | [link](https://github.com/c-ares/c-ares/pull/1189) |
| Contamination Level | low |
| Training Value Score | 6.0 |
| Training Verdict | medium |

## Problem Statement

Currently, c-ares accepts multiple OPT records in a single DNS response without rejecting the message. 

According to RFC 6891 Section 6.1.1: *"There MUST be at most one OPT pseudo-RR in the Additional Data section of a message. If a query message with more than one OPT RR is received, a FORMERR (Format Error) MUST be returned."*

Allowing a second OPT record could potentially overwrite extended RCODE bits or inject unexpected EDNS options. For comparison, resolvers like unbound reject a second OPT record with `FORMERR` during message parsing.

**To Reproduce**
Parse a crafted DNS response containing more than one OPT record in the Additional Data section using `ares_dns_parse`. c-ares will successfully parse the response instead of throwing a format error.

**Expected behavior**
c-ares should reject the response, and `ares_dns_parse` should return `ARES_EBADRESP` when a second OPT record is encountered during parsing.

**Version info**
* **c-ares version:** `main` (Tested against commit `0752823`)

**Additional context**
This was originally submitted to the c-ares security list, but it was agreed to be tracked as a standard protocol compliance bug rather than a security vulnerability.

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 1 |
| PASS_TO_PASS tests | 83 |
| Gold F2P count | 1 |
| Gold P2P count | 83 |
| Agent F2P passed | 1 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 1 | 27 |
| model_patch.patch (LLM output) | 1 | 20 |
| test_patch.patch (test changes) | 1 | 38 |

## FAIL_TO_PASS Tests

- `LibraryTest.ParseMultipleOptRejected`

## Test Command

```bash
cmake --build build -j2; build/bin/arestest --gtest_filter='LibraryTest.Parse*'
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
docker build -t swe-c-ares__c-ares-1137 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-c-ares__c-ares-1137 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
