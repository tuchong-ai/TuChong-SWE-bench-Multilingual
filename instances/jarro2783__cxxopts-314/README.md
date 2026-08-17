# jarro2783__cxxopts-314

## Overview

| Field | Value |
|---|---|
| Repository | [jarro2783/cxxopts](https://github.com/jarro2783/cxxopts) |
| Language | cpp |
| License | MIT |
| Version | `cpp-654d63dfae87` |
| Base Commit | `654d63dfae87` |
| Fix Commit | `b6135315a54d` |
| Fix Date | 2026-06-03 |
| Issue | [link](https://github.com/jarro2783/cxxopts/issues/314) |
| PR | [link](https://github.com/jarro2783/cxxopts/pull/499) |
| Contamination Level | medium |
| Training Value Score | 7.0 |
| Training Verdict | medium |

## Problem Statement

cxxopts rejects standard special floating-point values when they are supplied to options declared as `float`, `double`, or `long double`.

For example:

```cpp
cxxopts::Options options("special-floats");
options.add_options()
  ("double", "Double precision", cxxopts::value<double>())
  ("long-double", "Extended precision", cxxopts::value<long double>())
  ("positional", "Floats", cxxopts::value<std::vector<float>>());
```

Parsing arguments such as `--double inf`, `--long-double infinity`, and positional values `-inf` or `nan` should succeed. The resulting values must preserve whether they are infinite, their sign, or whether they are NaN. Invalid non-numeric values such as `abc` must continue to raise `cxxopts::exceptions::incorrect_argument_type`.

Currently, the special values are rejected instead of being returned as floating-point values.

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 2 |
| PASS_TO_PASS tests | 2 |
| Gold F2P count | 2 |
| Gold P2P count | 2 |
| Agent F2P passed | 2 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 1 | 68 |
| model_patch.patch (LLM output) | 1 | 63 |
| test_patch.patch (test changes) | 1 | 63 |

## FAIL_TO_PASS Tests

- `options`
- `options_no_regex`

## Test Command

```bash
cd build && ctest -V
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
docker build -t swe-jarro2783__cxxopts-314 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-jarro2783__cxxopts-314 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
