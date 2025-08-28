#!/usr/bin/env bash

set -eu

# tests/run.sh - run tests

source git-privacy

source tests/utils

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp

# ACT
# git privacy redact
redact
actual=$(git log --pretty=format:"%ai|%ci|%s")

# TEARDOWN
_teardown

# ASSERT
expected="2025-05-05 00:00:00 +0000|2026-06-06 00:00:00 +0000|old commit"
assert "$expected" "$actual"
