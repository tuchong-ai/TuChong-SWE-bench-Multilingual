# typescript-eslint__typescript-eslint-12003

## Overview

| Field | Value |
|---|---|
| Repository | [typescript-eslint/typescript-eslint](https://github.com/typescript-eslint/typescript-eslint) |
| Language | ts |
| License | MIT |
| Version | `ts-4fa6acd4cfa7` |
| Base Commit | `4fa6acd4cfa7` |
| Fix Commit | `c3f8ed5ddfa7` |
| Fix Date | 2026-04-08 |
| Issue | [link](https://github.com/typescript-eslint/typescript-eslint/issues/12003) |
| PR | [link](https://github.com/typescript-eslint/typescript-eslint/pull/12004) |
| Contamination Level | low |
| Training Value Score | 7.5 |
| Training Verdict | medium |

## Problem Statement

### Before You File a Bug Report Please Confirm You Have Done The Following...

- [x] I have tried restarting my IDE and the issue persists.
- [x] I have updated to the latest version of the packages.
- [x] I have [searched for related issues](https://github.com/typescript-eslint/typescript-eslint/issues?q=is%3Aissue+label%3A%22package%3A+eslint-plugin%22) and found none that matched my issue.
- [x] I have [read the FAQ](https://typescript-eslint.io/linting/troubleshooting) and my problem is not listed.

### Playground Link

https://typescript-eslint.io/play/#ts=5.9.2&fileType=.tsx&code=FAUwHgDg9gTgLgAgMZQHYGdEFsCeAVHCEAcQFcBDGAEwQF4EAKK8ucgLgVNQGtUoB3VAEoOzVggCW6BJhgTUAczoA%2BBAG9gCBDBBxSMVAjgxSIYAF8A3MFCRYiFBmz5CJCtQBMdRmPIeOXLwCwirqmtq6%2BobGphaWQA&eslintrc=N4KABGBEBOCuA2BTAzpAXGUEKQAIBcBPABxQGNoBLY-AWhXkoDt8B6Jge1tidmUQAmtAG4BDaKgwBtSImjQO0SABpMUcQHNJ6%2BPEhgAvgF1w2AyANA&tsconfig=N4KABGBEDGD2C2AHAlgGwKYCcDyiAuysAdgM6QBcYoEEkJemy0eAcgK6qoDCAFutAGsylBm3TgwAXxCSgA&tokens=false

### Repro Code

```TypeScript
// This should report `data` as unused (only used in type position) but doesn't                                  
export const myTypeGuard = (data: unknown): data is string => {                                                  
  return true                                                                                                    
};
```

### ESLint Config

```javascript
module.exports = {
  parser: "@typescript-eslint/parser",
  rules: {
    "@typescript-eslint/no-unused-vars": ["error"],
  },
};
```

### tsconfig

```jsonc

```

### Expected Result

I would expect `data` to be unused`

### Actual Result

no error is reported by the rule

### Additional Info

Also relevant:
```ts
// This should report `data` as unused (only used in type position) but doesn't                                  
export const myTypeGuard = (data: unknown): data is string => {                                                  
  return true                                                                                                    
};                                                                                                               
```
```ts
// This correctly reports `data2` as unused with message about type position                                     
export const myTypeGuard2 = (data2: unknown): typeof data2 => {                                                  
  return true                                                                                                    
};  
```

Discord discussion: https://discord.com/channels/1026804805894672454/1451903355440992307

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 1 |
| PASS_TO_PASS tests | 247 |
| Gold F2P count | 1 |
| Gold P2P count | 247 |
| Agent F2P passed | 1 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 3 | 76 |
| model_patch.patch (LLM output) | 1 | 35 |
| test_patch.patch (test changes) | 1 | 47 |

## FAIL_TO_PASS Tests

- `eslint-plugin tests/rules/no-unused-vars/no-unused-vars.test.ts > no-unused-vars > invalid > export const myTypeGuard = (data: unknown): data is string => { return true; };`

## Test Command

```bash
export NX_NO_CLOUD=true NX_DAEMON=false; CLAUDEDATA_TOOL_BIN="${CLAUDEDATA_TOOL_BIN:-$HOME/.claudedata-bin}"; mkdir -p "$CLAUDEDATA_TOOL_BIN"; printf '%s\n' '#!/bin/sh' 'exec corepack pnpm "$@"' > "$CLAUDEDATA_TOOL_BIN/pnpm"; printf '%s\n' '#!/bin/sh' 'exec corepack yarn "$@"' > "$CLAUDEDATA_TOOL_BIN/yarn"; chmod +x "$CLAUDEDATA_TOOL_BIN/pnpm" "$CLAUDEDATA_TOOL_BIN/yarn"; export PATH="$CLAUDEDATA_TOOL_BIN:$PATH"; if [ -f pnpm-lock.yaml ]; then corepack pnpm exec nx test eslint-plugin --run tests/rules/no-unused-vars/no-unused-vars.test.ts --reporter=verbose; elif [ -f yarn.lock ]; then corepack yarn exec nx test eslint-plugin --run tests/rules/no-unused-vars/no-unused-vars.test.ts --reporter=verbose; else npx nx test eslint-plugin --run tests/rules/no-unused-vars/no-unused-vars.test.ts --reporter=verbose; fi
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
docker build -t swe-typescript-eslint__typescript-eslint-12003 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-typescript-eslint__typescript-eslint-12003 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
