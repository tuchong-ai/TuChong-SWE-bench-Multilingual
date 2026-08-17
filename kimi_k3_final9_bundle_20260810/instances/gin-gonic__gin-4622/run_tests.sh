#!/bin/bash
# Verification script for gin-gonic__gin-4622
# FAIL_TO_PASS: ["TestSaveUploadedFileToExistingDir"]
# Runs the test command from environment.json

set -e

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
print("^(" + "|".join(dict.fromkeys(names)) + ")$")' context_test.go)"; [ "$__go_filter" != "^()$" ] && go test -v -count=1 -run "$__go_filter" .
