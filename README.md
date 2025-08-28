# git-privacy
Keep your coding hours private by amending author/committer date and time.

Simpler one-bash-script alternative to [EMPRI-DEVOPS/git-privacy](https://github.com/EMPRI-DEVOPS/git-privacy)

# Installation
copy `git-privacy` to where your `$PATH` can reach it.
e.g.:
```bash
cd $(mktemp -d)
git clone <THIS REPO>
cp git-privacy/git-privacy ~/.local/bin/
```

# Getting Started
`git-privacy` uses a post-commit hook to redact timestamps and a pre-push hook
to verify if timestamps are not being leaked.
Rest assured, nothing inside `.git/hooks/` is shared on `git push ...`,
therefore, you don't run the risk of ruining someone else's workflow.

## Usage
Setup `git-privacy` on a repository using:
```bash
git-privacy init
```
Now, all your next commits will have their timestamps' hours, minutes, seconds
and timezone info redacted to all zeroes (`00:00:00+0000`).

After installation, the commands `git-privacy redact` and `git-privacy verify` are
automatically run by the `post-commit` and `pre-push` hooks respectively,
however you can run them manually to further redact older commits.

To redact the last commit timestamp use:
```bash
git-privacy redact
```
By default, `git-privacy redact` only changes the last commit.

To verify that none of your local commits in the current branch are leaking
timestamps use:
```bash
git-privacy verify
```
By default, `git-privacy verify` checks only un-pushed commits.

Run `git privacy help` for a list of all commands.

## Make git-privacy available by default
To make `git-privacy` work by default in all new repos,
simply init it on your [git template](https://git-scm.com/docs/git-init#_template_directory)
```bash
cp -r /usr/share/git-core/templates ~/.local/share/git/privacy-template
cd ~/.local/share/git/privacy-template
git-privacy init
git config --global init.templatedir ~/.local/share/git/privacy-template
```

You can also install it directly on the default template
`/usr/share/git-core/templates`
