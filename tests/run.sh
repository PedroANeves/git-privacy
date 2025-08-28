#!/usr/bin/env bash

set -xeu

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
privacy_redact
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
privacy_redact
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
privacy_redact
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

###############################################################################
: test init sets up post-commit hook
###############################################################################

# SETUP
_setup playground

# PREPARE

# ACT
# git privacy init
privacy_init
actual="$(cat .git/hooks/post-commit)"

# TEARDOWN
_teardown

# ASSERT
read -d '' expected << 'EOF' || true
#!/usr/bin/env bash

# git-privacy hook to redact
# set environment var GIT_PRIVACY_DISABLE to skip redacting.

set -e

. "$(pwd)/$(dirname "$0")"/git-privacy
privacy_redact
EOF

assert "$expected" "$actual"

###############################################################################
: test init makes hook executable
###############################################################################

# SETUP
_setup playground

# PREPARE

# ACT
# git privacy init
privacy_init
actual="$(test -x .git/hooks/post-commit; echo $?)"

# TEARDOWN
_teardown

# ASSERT
assert "0" "$actual"

###############################################################################
: test init copies git-privacy to .git/
###############################################################################

# SETUP
_setup playground

# PREPARE

# ACT
# git privacy init
privacy_init
actual="$(find .git/hooks/ -name 'git-privacy')"

# TEARDOWN
_teardown

# ASSERT
assert ".git/hooks/git-privacy" "$actual"

