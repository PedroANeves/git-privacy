#!/usr/bin/env bash

# tests.sh - run tests

die() { echo "$*" 1>&2 ; exit 1; }

BASE=$(mktemp -d)
pushd "$BASE" > /dev/null || exit
mkdir playground

pushd playground > /dev/null || exit

git init > /dev/null
GIT_AUTHOR_DATE=2000-01-01T01:01:01+0000 \
  GIT_COMMITTER_DATE=2000-02-02T02:02:02+0000 \
  git commit --allow-empty -m 'old commit' > /dev/null
  actual=$(git log --pretty=format:"%ai|%ci|%s")
popd > /dev/null || exit


expected="2000-01-01 00:00:00 +0000|2000-02-02 00:00:00 +0000|old commit"
if [[ "$actual" == "$expected" ]]; then
  echo OK
else
  echo "test at $BASE"
  echo "expected: $expected"
  echo "actual  : $actual"
fi

popd > /dev/null || exit

