#!/usr/bin/env bash

set -eu

# tests.sh - run tests

die() { echo "$*" 1>&2 ; exit 1; }

source git-privacy

# tests location setup
rm -fr playground
mkdir -p playground

# old commit with timestamp
pushd playground > /dev/null || exit
git init
GIT_AUTHOR_DATE=2025-05-05T05:05:05+0500 \
  GIT_COMMITTER_DATE=2026-06-06T06:06:06+0600 \
  git commit --allow-empty -m 'old commit'

# git privacy redact
redact
actual=$(git log --pretty=format:"%ai|%ci|%s")
popd > /dev/null || exit

# assert
expected="2025-05-05 00:00:00 +0000|2026-06-06 00:00:00 +0000|old commit"
if [[ "$actual" == "$expected" ]]; then
  echo OK
  exit 0
else
  echo "expected: $expected"
  echo "actual  : $actual"
  exit 1
fi
