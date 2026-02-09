#!/bin/bash
set -euo pipefail

function fail { >&2 echo -e "ERROR: $1"; exit 1; }

(( $# == 2 )) || fail "Wrong number of arguments\nUsage: $0 <solidity repo commit/branch/tag> <commit message>"
git config remote.english.url || fail "Remote 'english' is not defined"
SOLIDITY_REF="$1"
COMMIT_MESSAGE="$2"

# ASSUMPTIONS:
# - We're in the root directory of a working copy of the translation repository.
# - Remote 'english' exists and points at the main Solidity repository.
# - Working copy is clean, with no modified or untracked files.

# Try to merge changes from the main repository. Anything changed at the same time in the translation
# and in the main repo will result in a conflict and will make the command fail. This is fine.
# We want to include the conflict markers as a part of the merge commit so that they're easy to spot in the PR.
# The command will also fail if in the main repo there were modifications to files outside
# of docs/ (these files are deleted in translation repos). These are the conflicts we want to ignore.
if ! git merge "${SOLIDITY_REF}" -m "$COMMIT_MESSAGE"; then
    # Unstage everything without aborting the merge.
    # This also "resolves" conflicts by keeping conflicted files as is including the conflict markers.
    git reset .

    # The only changes from the main repo that we're interested in are those in docs/ and
    # CMakeLists.txt, which is parsed by our Sphinx config to determine version. Stage them.
    git add docs/ CMakeLists.txt .readthedocs.yml

    # Reset any files seen by git as modified/deleted to the state from before the merge.
    # We need this for files outside of docs/ that happen to match the path of some file that exists
    # in the main repo, for example README.md or .gitignore. We do not copy these when setting up a
    # translation repo but to git they look like files from the main repo that need to be synced.
    files_to_reset=$(git ls-files --modified --deleted)
    if [[ $files_to_reset != "" ]]; then
        # NOTE: If the file list passed to `git checkout` is empty, git aborts the merge. We don't want that.
        git ls-files --modified --deleted | xargs git checkout --
    fi

    # All the other files from the original merge commit are now untracked. We don't want them in the PR.
    git clean -d --force

    # Finalize the merge. Should create a commit with the message we specified in the original command.
    git commit --no-edit
fi
