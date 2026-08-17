#!/bin/bash
# Verification script for jhy__jsoup-2476
# FAIL_TO_PASS: ["org.jsoup.safety.CleanerTest::canonicalizesNofollowEnforcedAttribute", "org.jsoup.safety.CleanerTest::canonicalizesEnforcedAttributes"]
# Test command: __maven_rc=0; mvn clean test -Dtest=CleanerTest || __maven_rc=$?; find . -path '*/target/surefire-reports/TEST-*.xml' -type f -exec cat {} \; 2>/dev/null; [ "$__maven_rc" -eq 0 ]

set -e

__maven_rc=0; mvn clean test -Dtest=CleanerTest || __maven_rc=$?; find . -path '*/target/surefire-reports/TEST-*.xml' -type f -exec cat {} \; 2>/dev/null; [ "$__maven_rc" -eq 0 ]
