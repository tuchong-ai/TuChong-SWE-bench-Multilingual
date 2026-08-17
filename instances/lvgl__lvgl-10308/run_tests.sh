#!/bin/bash
# Verification script for lvgl__lvgl-10308
# FAIL_TO_PASS: ["test_slider", "test_bar"]
# Test command: . "$HOME/.claudedata-lvgl-venv/bin/activate"; __lvgl_build="${CLAUDEDATA_LVGL_BUILD_DIR:-$HOME/.cache/claudedata/lvgl-build}"; __lvgl_jobs="${CLAUDEDATA_LVGL_BUILD_JOBS:-4}"; if [ ! -f "$__lvgl_build/build.ninja" ]; then cmake -S tests -B "$__lvgl_build" -GNinja -DCMAKE_BUILD_TYPE=Debug -DOPTIONS_TEST_SYSHEAP=1; fi; cmake --build "$__lvgl_build" --parallel "$__lvgl_jobs" --target test_bar test_slider test_array; ctest --test-dir "$__lvgl_build" --timeout 300 --parallel "$__lvgl_jobs" --output-on-failure --tests-regex '^(test_bar|test_slider|test_array)$'

set -e

. "$HOME/.claudedata-lvgl-venv/bin/activate"; __lvgl_build="${CLAUDEDATA_LVGL_BUILD_DIR:-$HOME/.cache/claudedata/lvgl-build}"; __lvgl_jobs="${CLAUDEDATA_LVGL_BUILD_JOBS:-4}"; if [ ! -f "$__lvgl_build/build.ninja" ]; then cmake -S tests -B "$__lvgl_build" -GNinja -DCMAKE_BUILD_TYPE=Debug -DOPTIONS_TEST_SYSHEAP=1; fi; cmake --build "$__lvgl_build" --parallel "$__lvgl_jobs" --target test_bar test_slider test_array; ctest --test-dir "$__lvgl_build" --timeout 300 --parallel "$__lvgl_jobs" --output-on-failure --tests-regex '^(test_bar|test_slider|test_array)$'
