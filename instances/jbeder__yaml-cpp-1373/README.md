# jbeder__yaml-cpp-1373

## Overview

| Field | Value |
|---|---|
| Repository | [jbeder/yaml-cpp](https://github.com/jbeder/yaml-cpp) |
| Language | cpp |
| License | MIT |
| Version | `cpp-1bff0699f867` |
| Base Commit | `1bff0699f867` |
| Fix Commit | `29a6f43950ce` |
| Fix Date | 2026-07-02 |
| Issue | [link](https://github.com/jbeder/yaml-cpp/issues/1373) |
| PR | [link](https://github.com/jbeder/yaml-cpp/pull/1437) |
| Contamination Level | low |
| Training Value Score | 6.0 |
| Training Verdict | medium |

## Problem Statement

A node tagged with the YAML secondary tag handle `!!str` is emitted incorrectly,
while ordinary primary-handle tags such as `!mytag` must continue to work.

Reproduce with this minimal example:

```cpp
YAML::Node root_node{};
YAML::Node string_node{"hello"};
string_node.SetTag("!!str");
root_node["some_string"] = string_node;
root_node["some_int"] = 2;
std::cout << root_node << std::endl;
```

The output is truncated after the tag instead of preserving the tagged value and
the following mapping entry. The exact emitted mapping (without an additional
trailing newline) should be `some_string: !!str hello\nsome_int: 2`. A primary
tag such as `!mytag` should likewise remain `v: !mytag hello`.

This report concerns the `!!str` secondary-handle case shown above; it does not
require behavior for unrelated secondary handles.


## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 1 |
| PASS_TO_PASS tests | 4 |
| Gold F2P count | 1 |
| Gold P2P count | 4 |
| Agent F2P passed | 1 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 1 | 18 |
| model_patch.patch (LLM output) | 1 | 25 |
| test_patch.patch (test changes) | 1 | 38 |

## FAIL_TO_PASS Tests

- `NodeTest.EmitSetTagSecondaryHandle`

## Test Command

```bash
cd build && __yaml_runner=./test/yaml-cpp-tests; if [ ! -x "$__yaml_runner" ]; then if [ -x ./test/run-tests ]; then __yaml_runner=./test/run-tests; else __yaml_runner=./run-tests; fi; fi; __yaml_filter="$(cd .. && python3 -c 'import re
import subprocess
import sys

test_re = re.compile(
    r"^\s*TEST(?:_F)?\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*"
    r"([A-Za-z_][A-Za-z0-9_]*)\s*\)"
)
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
            current = f"{match.group(1)}.{match.group(2)}"
            if guards < 2:
                names.append(current)
                guards += 1
        if number in changed and current:
            names.append(current)
print(":".join(dict.fromkeys(names)))' test/integration/load_node_test.cpp)"; [ -n "$__yaml_filter" ] && "$__yaml_runner" --gtest_filter="$__yaml_filter"
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
docker build -t swe-jbeder__yaml-cpp-1373 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-jbeder__yaml-cpp-1373 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
