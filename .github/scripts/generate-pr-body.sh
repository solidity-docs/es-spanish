#!/bin/bash
set -euo pipefail

function modified_file_list {
    commit_hash=$(git rev-parse --verify develop)
    git status --short |
        grep "docs" |
        awk '{print "- [ ] ["$2"](https://github.com/ethereum/solidity/tree/'"${commit_hash}"'/"$2")"}'
}

function today_utc {
    date --utc +%Y-%m-%d
}

function sync_commit_human_readable_id {
    git describe --tags --always develop
}

function sync_commit_link {
    local commit_hash truncated_commit_hash
    commit_hash=$(git rev-parse --verify develop)
    truncated_commit_hash=$(echo "$commit_hash" | head -c 8)

    echo "[${truncated_commit_hash}](https://github.com/ethereum/solidity/tree/${commit_hash})"
}

function title {
    echo "English documentation updates up to $(sync_commit_human_readable_id) ($(today_utc))"
}

# shellcheck disable=SC2016 # Any Backticks here are markdown syntax not Bash expressions
function pr_body {
    echo "This is an automatically-generated sync PR to bring this translation repository up to date with the state of the English documentation as of $(today_utc) (commit $(sync_commit_link))."
    echo
    echo "### How to work on a sync PR"
    echo "#### Resolve conflicts and translate newly added text"
    echo "- The PR includes all documentation changes from the main repository since the last time a sync PR was merged. " \
         "If this translation repository is fully caught up with the English version, translate any newly added English text you see here by pushing more commits to the PR. " \
         "However, if the translation is incomplete, you may prefer to leave the text added in this PR and add it to your translation checklist to handle at a later time."
    echo "- Scan the PR for merge conflict markers. " \
         "If there were changes in the English text that has already been translated, the PR will contain merge conflicts that need to be resolved:"
    echo '    ```diff'
    echo '    <<<<<<< HEAD'
    echo '        El valor más grande representable por el tipo ``T``.'
    echo '    ======='
    echo '        The smallest value representable by type ``T``.'
    echo '    >>>>>>> 800088e38b5835ebdc71e9ba5299a70a5accd7c2'
    echo '    ```'
    echo "    The top part of the conflict is the current translation (corresponding to the old English text), the bottom shows the new English text. " \
         "To solve the conflict simply translate the new text, possibly reusing parts of the current translation. " \
         "**After doing so, do not forget to remove the conflict markers.**"
    echo "- You may get conflicts also if there were structual changes that did not affect the meaning of the text and therefore do not require retranslation. " \
         "For example when text is moved from one page to another, you will find matching conflicts in two places and the solution is to move the translation to the new spot. " \
         "If only whitespace changed, it may even seem like there was no change at all but if there is a conflict, there is always a reason, however trivial it may be." \
         "Be careful, though, because there is a possibility that the text was both moved **and** modified. "
    echo
    echo "#### Work on one sync PR at a time"
    echo "- Sync PRs are produced by the translation bot in regular intervals as long as there are changes in the English documentation. " \
         "You will not lose any updates by closing this PR. " \
         "The next sync PR will also include them. " \
         "The latest sync PR will always include all changes that need to be done. " \
         "If you haven't worked on any sync PR yet and there are several open sync PRs in your repo, choose the latest (newest) one to get started."
    echo "- It is recommended to work only on one sync PR at a time. " \
         "Close this PR if you are already working on a different one."
    echo "- Once you merge this PR, the conflict resolutions and new commits you pushed to it are likely to cause conflicts with other open sync PRs. " \
         "It is possible solve these conflicts if you are proficient with git and fully understand what changed in which PR, " \
         "but for simplicity it is recommended to close all pending sync PRs and wait for a fresh one, which will no longer include the merged changes."
    echo
    echo "#### Do not squash merge or rebase this PR"
    echo "Rebasing or squashing a sync PR erases the information about the commits that the changes originally came from, which will result in extra conflicts in the next sync PR."
    echo "If you do it by accident, don't worry - simply make sure to handle the next sync PR properly, which will restore the missing commits."
    echo
    echo "### Review checklist"
    echo "The following files were modified in this pull request. " \
         "Please review them before merging the PR:"
    modified_file_list
}

printf "pr_title=%s\n" "$(title)"             >> "$GITHUB_ENV"
printf "pr_body<<EOF\n%s\nEOF\n" "$(pr_body)" >> "$GITHUB_ENV"
