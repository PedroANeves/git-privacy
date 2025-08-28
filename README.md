# git-privacy
Keep your coding hours private by amending author/committer date and time.

Simpler one-bash-script alternative to [EMPRI-DEVOPS/git-privacy](https://github.com/EMPRI-DEVOPS/git-privacy)

# Installation
copy `git-privacy` to where your `$PATH` can reach it.

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

To redact the last commit timestamp use
```bash
git-privacy redact
```

## Make git-privacy available by default
To make `git-privacy` work by default in all new repos,
simply init it on your git template
```bash
cp -r /usr/share/git-core/templates "$HOME"/.local/share/git/privacy-template
cd "$HOME"/.local/share/git/privacy-template
git-privacy init
git config --global init.templatedir "$HOME"/.local/share/git/privacy-template
```

You can also install it directly on the default template
`/usr/share/git-core/templates`
