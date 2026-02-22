# Guide to Rewriting Git History

This guide explains how to change the author information for past commits in a git repository.

## 1. Configure Git User Information

Set your name and email for the current repository. This will be used for future commits.

```bash
git config user.name "your-username"
git config user.email "your-email@example.com"
```

## 2. Rewrite Commit History

This step will rewrite the history of the repository to change the author information on past commits.

**Warning:** This is a destructive operation. It will change the commit hashes of all rewritten commits.

We will use `git filter-branch` for this.

```bash
git filter-branch --env-filter '
OLD_EMAIL="old-email@example.com"
CORRECT_NAME="Your Name"
CORRECT_EMAIL="your-email@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

Replace `old-email@example.com`, `Your Name`, and `your-email@example.com` with the appropriate values.

## 3. Push Changes to Remote Repository

After rewriting the history, you need to force push the changes to the remote repository.

**Warning:** This will overwrite the history of the remote repository. This can be disruptive for other collaborators.

```bash
git push --force origin <branch-name>
```

Replace `<branch-name>` with the name of the branch you want to push.

## 4. Clean Up Backup References

`git filter-branch` creates backup references of the original branches. After you have successfully pushed the changes, you can remove these backups.

```bash
git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
```

This will clean up your local repository.
