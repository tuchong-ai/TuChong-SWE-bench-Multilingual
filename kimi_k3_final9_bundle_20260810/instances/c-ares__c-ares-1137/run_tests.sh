#!/bin/bash
# Verification script for c-ares__c-ares-1137
# FAIL_TO_PASS: ["LibraryTest.ParseMultipleOptRejected"]
# Test command: cmake --build build -j2; build/bin/arestest --gtest_filter='LibraryTest.Parse*'

set -e

cmake --build build -j2; build/bin/arestest --gtest_filter='LibraryTest.Parse*'
