#!/usr/bin/env bash

set -eu

# tests/run.sh - run tests

source git-privacy

source tests/utils

###############################################################################
# test redact last commit
###############################################################################

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

###############################################################################
# test redact preserves untracked files
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp
echo 'data' > f

# ACT
# git privacy redact
redact
actual="$(git --no-pager diff --no-index -- /dev/null f | cat)"

# TEARDOWN
_teardown

# ASSERT
read -d '' expected << EOF || true
diff --git a/f b/f
new file mode 100644
index 0000000..1269488
--- /dev/null
+++ b/f
@@ -0,0 +1 @@
+data
EOF

assert "$expected" "$actual"

###############################################################################
# test redact preserves staged files
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp
echo 'data' > f

# ACT
# git privacy redact
git add f
redact
actual="$(git --no-pager status | cat)"

# TEARDOWN
_teardown

# ASSERT
read -d '' expected << EOF || true
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   f

EOF

assert "$expected" "$actual"
