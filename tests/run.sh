#!/usr/bin/env bash

set -eu

# tests/run.sh - run tests

die() { echo "$*" 1>&2 ; exit 1; }

source git-privacy

source tests/utils

# SETUP
_setup playground

# PREPARE
# old commit with timestamp
git init
GIT_AUTHOR_DATE=2025-05-05T05:05:05+0500 \
  GIT_COMMITTER_DATE=2026-06-06T06:06:06+0600 \
  git commit --allow-empty -m 'old commit'

# ACT
# git privacy redact
redact
actual=$(git log --pretty=format:"%ai|%ci|%s")

# TEARDOWN
_teardown

# ASSERT
expected="2025-05-05 00:00:00 +0000|2026-06-06 00:00:00 +0000|old commit"
assert "$expected" "$actual"
