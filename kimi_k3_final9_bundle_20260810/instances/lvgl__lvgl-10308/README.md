# lvgl__lvgl-10308

## Overview

| Field | Value |
|---|---|
| Repository | [lvgl/lvgl](https://github.com/lvgl/lvgl) |
| Language | c |
| License | MIT |
| Version | `c-7da9cae8837c` |
| Base Commit | `7da9cae8837c` |
| Fix Commit | `8274446cecf5` |
| Fix Date | 2026-07-02 |
| Issue | [link](https://github.com/lvgl/lvgl/issues/10308) |
| PR | [link](https://github.com/lvgl/lvgl/pull/10320) |
| Contamination Level | low |
| Training Value Score | 7.0 |
| Training Verdict | medium |

## Problem Statement

### LVGL version

Discovered in 9.3.0, exists up to master commit #10009

### Platform

Should not be related, but in my case it was STM32H753 on custom PCB.

### What happened?

I’m using LVGL9.3 but master #10009 is affected too. I use slider widget to seek in music file with millisecond precision. One of files that I tested has 180 minutes of audio data (so slider range was from 0 up to about 10800000 milliseconds). Slider width is about 600px. When I set value higher than about 4020000 I noticed that knob and bar moved to start (rolled over). I started looking what causing issue, due to 4 millions are within int32 and found quite a lot of lines of code with multiplication of int32 values without widening to int64.

In slider.c # 10009 widget issue may happen at least in lines: 605 and 624.
In bar.c # 10009 widget issue may happen at least in lines 436 - 463 where ever multiplication happening between geometry and values.

For example slider.c line 605 original:
`new_value = (new_value * range + indic_w / 2) / indic_w;`
I fixed in my project like:
`new_value = (int32_t)(((int64_t)new_value * (int64_t)range + (int64_t)(indic_w / 2)) / indic_w);`

In bar.c line 462 original:
`anim_cur_value_x = (int32_t)((int32_t)anim_length * (bar->cur_value - bar->min_value)) / range;`
I fixed in my project like:
`anim_cur_value_x = (int32_t)(((int64_t)anim_length * (int64_t)(bar->cur_value - bar->min_value)) / (int64_t)range);`


### How to reproduce?

The way to reproduce is to set min/max values close to int32_t limits. In my case value above 4020000 within range 0...10800000 and width of about 600px was enough.

## Test Results

| Metric | Value |
|---|---|
| FAIL_TO_PASS tests | 2 |
| PASS_TO_PASS tests | 1 |
| Gold F2P count | 2 |
| Gold P2P count | 1 |
| Agent F2P passed | 2 |
| Agent P2P regressed | 0 |
| Graded resolved | True |

## Patch Summary

| Patch | Files Changed | Lines |
|---|---|---|
| gold_patch.patch (ground truth) | 2 | 64 |
| model_patch.patch (LLM output) | 2 | 73 |
| test_patch.patch (test changes) | 2 | 156 |

## FAIL_TO_PASS Tests

- `test_slider`
- `test_bar`

## Test Command

```bash
. "$HOME/.claudedata-lvgl-venv/bin/activate"; __lvgl_build="${CLAUDEDATA_LVGL_BUILD_DIR:-$HOME/.cache/claudedata/lvgl-build}"; __lvgl_jobs="${CLAUDEDATA_LVGL_BUILD_JOBS:-4}"; if [ ! -f "$__lvgl_build/build.ninja" ]; then cmake -S tests -B "$__lvgl_build" -GNinja -DCMAKE_BUILD_TYPE=Debug -DOPTIONS_TEST_SYSHEAP=1; fi; cmake --build "$__lvgl_build" --parallel "$__lvgl_jobs" --target test_bar test_slider test_array; ctest --test-dir "$__lvgl_build" --timeout 300 --parallel "$__lvgl_jobs" --output-on-failure --tests-regex '^(test_bar|test_slider|test_array)$'
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
docker build -t swe-lvgl__lvgl-10308 .

# 2. Apply patches and run tests
docker run --rm -v "$(pwd)/model_patch.patch:/tmp/model.patch" -v "$(pwd)/test_patch.patch:/tmp/test.patch" swe-lvgl__lvgl-10308 bash -c '
  cd /testbed
  git apply /tmp/test.patch   # apply test changes
  git apply /tmp/model.patch  # apply LLM solution
  bash run_tests.sh           # run regression tests
'
```
