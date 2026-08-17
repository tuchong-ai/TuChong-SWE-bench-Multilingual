# jhy__jsoup-2476

## Overview

| Field | Value |
|---|---|
| Repository | [jhy/jsoup](https://github.com/jhy/jsoup) |
| Language | java |
| License | MIT |
| Version | `java-e640ca8a7241` |
| Base Commit | `e640ca8a7241` |
| Fix Commit | `7c32b7e10518` |
| Fix Date | 2026-03-08 |
| Issue | [link](https://github.com/jhy/jsoup/issues/2476) |
| PR | N/A |
| Contamination Level | low |
| Training Value Score | 7.0 |
| Training Verdict | medium |

## Problem Statement

As a follow-up to #2475, I noticed another small `Cleaner` issue when working with a parsed `Document` that preserves attribute case.

If an element already has an attribute that matches an enforced attribute, but with different key case, the cleaned output can contain both versions of the attribute instead of a single enforced one.

For example:

```java
Document dirty = Jsoup.parse("<a REL='external'>One</a>", "",
    Parser.htmlParser().settings(ParseSettings.preserveCase));
Cleaner cleaner = new Cleaner(Safelist.none()
    .addTags("a")
    .addEnforcedAttribute("a", "rel", "external"));

cleaner.clean(dirty).body().html();
// was:    <a REL="external" rel="external">One</a>
// should: <a rel="external">One</a>
```

The same thing can happen with the standard `Safelist.basic()` handling of `rel="nofollow"` on external links.

The intended behavior is that when an enforced attribute applies, the cleaned output should contain that attribute once, using the enforced key and value. A case-variant source attribute should be replaced, not duplicated.


## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 2 |
| PASS_TO_PASS tests | 55 |
| Gold F2P count | 2 |
| Gold P2P count | 55 |
| Agent F2P passed | 2 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 2 | 27 |
| model_patch.patch (LLM output) | 1 | 18 |
| test_patch.patch (test changes) | 1 | 33 |

## FAIL_TO_PASS Tests

- `org.jsoup.safety.CleanerTest#canonicalizesNofollowEnforcedAttribute`
- `org.jsoup.safety.CleanerTest#canonicalizesEnforcedAttributes`

## Test Command

```bash
__maven_rc=0; mvn clean test -Dtest=CleanerTest || __maven_rc=$?; find . -path '*/target/surefire-reports/TEST-*.xml' -type f -exec cat {} \; 2>/dev/null; [ "$__maven_rc" -eq 0 ]
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
docker build -t swe-jhy__jsoup-2476 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-jhy__jsoup-2476 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
