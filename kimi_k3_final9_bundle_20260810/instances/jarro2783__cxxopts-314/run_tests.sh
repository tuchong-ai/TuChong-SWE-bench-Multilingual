#!/bin/bash
# Verification script for jarro2783__cxxopts-314
# FAIL_TO_PASS: ["options", "options_no_regex"]
# Test command: cd build && ctest -V

set -e

cd build && ctest -V
