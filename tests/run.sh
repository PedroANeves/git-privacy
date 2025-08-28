#!/usr/bin/env bash

set -xeu

# tests/run.sh - run tests

source ./git-privacy

source tests/utils

###############################################################################
: test git-privacy by itself does not do anything
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp

# ACT
# git privacy
actual=$(../../git-privacy)

# TEARDOWN
_teardown

# ASSERT
expected=""
assert "$expected" "$actual"

###############################################################################
: test git-privacy command runs that command
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp

# ACT
# git privacy
actual=$(../../git-privacy -v)

# TEARDOWN
_teardown

# ASSERT
expected="git-privacy v$git_privacy_version"
assert "$expected" "$actual"

###############################################################################
: test redact last commit
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
: test redact BRANCH to redact all commits on branch
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
: test redact preserves staged files
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

###############################################################################
: test verify return errors if you have leaked timestamps
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_clear_timestamp

# ACT
# git privacy verify
actual="$(privacy_verify; echo $?)"

# TEARDOWN
_teardown

# ASSERT
expected="branch has no upstream set, checking all commits.
leaked timestamps:
ddea085|2025-05-05 05:05:05 +0500|2026-06-06 06:06:06 +0600
1"
assert "$expected" "$actual"

###############################################################################
: test verify return no errors if you only have redacted timestamps
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_redacted_timestamp

# ACT
# git privacy verify
actual="$(privacy_verify; echo $?)"

# TEARDOWN
_teardown

# ASSERT
expected="branch has no upstream set, checking all commits.
0"
assert "$expected" "$actual"

###############################################################################
: test verify return error if even a single commit has leaked timestamps
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_redacted_timestamp
commit_with_redacted_timestamp
commit_with_clear_timestamp
commit_with_redacted_timestamp
commit_with_redacted_timestamp

# ACT
# git privacy verify
actual="$(privacy_verify; echo $?)"

# TEARDOWN
_teardown

# ASSERT
expected="branch has no upstream set, checking all commits.
leaked timestamps:
f7176c6|2025-05-05 05:05:05 +0500|2026-06-06 06:06:06 +0600
1"
assert "$expected" "$actual"

###############################################################################
: test verify by defaults only check local only commits
###############################################################################

# SETUP
_setup playground

# PREPARE
commit_with_redacted_timestamp
commit_with_redacted_timestamp
commit_with_clear_timestamp
commit_with_redacted_timestamp
commit_with_redacted_timestamp

git init --bare ./o.git/
git remote add origin ./o.git/
git push -u origin master

commit_with_redacted_timestamp
commit_with_redacted_timestamp
commit_with_redacted_timestamp

# ACT
# git privacy verify
actual="$(privacy_verify; echo $?)"

# TEARDOWN
_teardown

# ASSERT
expected="branch has upstream set, checking local commits only.
0"
assert "$expected" "$actual"

###############################################################################
: test version prints version
###############################################################################

# SETUP
_setup playground

# PREPARE

# ACT
# git privacy version
actual="$(privacy_version)"

# TEARDOWN
_teardown

# ASSERT

assert "git-privacy v$git_privacy_version" "$actual"

###############################################################################
: test help prints help
###############################################################################

# SETUP
_setup playground

# PREPARE

# ACT
# git privacy help
actual="$(privacy_help)"

# TEARDOWN
_teardown

# ASSERT
read -d '' expected << EOF || true
git privacy
Usage:  git privacy [init|redact|verify]
  or:   git privacy [--version]
  or:   git privacy [--help|help|h]

init                installs git privacy on current git repo and
                    setup post-commit and pre-push hooks.

redact              used automaticaly by post-commit hook to redact
                    commiter and author timestamps.

verify              used automaticaly by pre-push hook to check if
                    current branch does not has any leaked timestamps.
                    by default, only checks non pushed commits.

-v, --version       prints current version.
-h, --help, help    prints this help.
EOF

assert "$expected" "$actual"

