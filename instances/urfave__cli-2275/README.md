# urfave__cli-2275

## Overview

| Field | Value |
|---|---|
| Repository | [urfave/cli](https://github.com/urfave/cli) |
| Language | go |
| License | MIT |
| Version | `go-a2d0cf1d520d` |
| Base Commit | `a2d0cf1d520d` |
| Fix Commit | `d3f95867d389` |
| Fix Date | 2026-03-25 |
| Issue | [link](https://github.com/urfave/cli/issues/2275) |
| PR | [link](https://github.com/urfave/cli/pull/2295) |
| Contamination Level | low |
| Training Value Score | 7.0 |
| Training Verdict | medium |

## Problem Statement

## My urfave/cli version is

_**v3.7.0**_

## Checklist

- [x] Are you running the latest v3 release? The list of releases is [here](https://github.com/urfave/cli/releases).
- [x] Did you check the manual for your release? The v3 manual is [here](https://cli.urfave.org/v3/getting-started/)
- [x] Did you perform a search about this problem? Here's the [GitHub guide](https://help.github.com/en/github/managing-your-work-on-github/using-search-to-filter-issues-and-pull-requests) about searching.

## Dependency Management

<!--
  Delete any of the following that do not apply:
-->

- My project is using go modules.
- My project is automatically ~downloading~ updating the latest version. (via Renovate)

## Describe the bug

It appears that the order in which `Flag.Action` is called is not deterministic

## To reproduce

```go
package debug_test

import (
	"context"
	"fmt"
	"testing"

	"github.com/urfave/cli/v3"
)

func RunCli(args []string) string {
	str := ""

	cmd := &cli.Command{
		Flags:    []cli.Flag{},
		Action: func(_ context.Context, cmd *cli.Command) error {
			return nil
		},
	}

	for _, f := range []string{"a", "b", "c"} {
		cmd.Flags = append(cmd.Flags, &cli.BoolFlag{
			Name: f,
			Action: func(_ context.Context, _ *cli.Command, _ bool) error {
				str += f

				return nil
			},
		})
	}

	if err := cmd.Run(context.Background(), args); err != nil {
		fmt.Printf("%s\n", err)
	}

	return str
}

type Case struct {
	Name string
	Args []string
}

func Test_run(t *testing.T) {
	tests := []Case{
		{
			Name: "abc",
			Args: []string{"", "--a", "--b", "--c"},
		},
		{
			Name: "bca",
			Args: []string{"", "--b", "--c", "--a"},
		},
		{
			Name: "cba",
			Args: []string{"", "--c", "--b", "--a"},
		},
	}
	for _, tt := range tests {
		t.Run(tt.Name, func(t *testing.T) {
			str := RunCli(tt.Args)

			if str != "abc" {
				t.Errorf("expected 'abc' got '%s'", str)
			}
		})
	}
}
```

## Observed behavior

```
❯ go test ./cmd/osv-scanner/debug/... -count 5
--- FAIL: Test_run (0.00s)
    --- FAIL: Test_run/bca (0.00s)
        debug_test.go:64: expected 'abc' got 'bca'
    --- FAIL: Test_run/cba (0.00s)
        debug_test.go:64: expected 'abc' got 'acb'
--- FAIL: Test_run (0.00s)
    --- FAIL: Test_run/bca (0.00s)
        debug_test.go:64: expected 'abc' got 'bca'
    --- FAIL: Test_run/cba (0.00s)
        debug_test.go:64: expected 'abc' got 'bac'
--- FAIL: Test_run (0.00s)
    --- FAIL: Test_run/cba (0.00s)
        debug_test.go:64: expected 'abc' got 'bac'
--- FAIL: Test_run (0.00s)
    --- FAIL: Test_run/abc (0.00s)
        debug_test.go:64: expected 'abc' got 'cab'
    --- FAIL: Test_run/bca (0.00s)
        debug_test.go:64: expected 'abc' got 'cab'
    --- FAIL: Test_run/cba (0.00s)
        debug_test.go:64: expected 'abc' got 'cba'
--- FAIL: Test_run (0.00s)
    --- FAIL: Test_run/abc (0.00s)
        debug_test.go:64: expected 'abc' got 'bca'
    --- FAIL: Test_run/bca (0.00s)
        debug_test.go:64: expected 'abc' got 'bca'
    --- FAIL: Test_run/c

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 1 |
| PASS_TO_PASS tests | 2 |
| Gold F2P count | 1 |
| Gold P2P count | 2 |
| Agent F2P passed | 1 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 1 | 32 |
| model_patch.patch (LLM output) | 1 | 41 |
| test_patch.patch (test changes) | 1 | 59 |

## FAIL_TO_PASS Tests

- `TestFlagActionOrder`

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
print("^(" + "|".join(dict.fromkeys(names)) + ")$")' command_test.go)"; [ "$__go_filter" != "^()$" ] && go test -v -count=1 -run "$__go_filter" .
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
docker build -t swe-urfave__cli-2275 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-urfave__cli-2275 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
