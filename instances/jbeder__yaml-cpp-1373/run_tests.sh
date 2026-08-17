#!/bin/bash
# Verification script for jbeder__yaml-cpp-1373
# FAIL_TO_PASS: ["NodeTest.EmitSetTagSecondaryHandle"]
# Runs the test command from environment.json

set -e

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
