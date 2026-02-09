#!/bin/bash
set -euo pipefail

# This script creates sync branches matching tagged releases in the main Solidity repository.
# The result is a sync commit and a branch. The script does NOT push the branch or create a PR.

# ASSUMPTIONS:
# - The current directory already contains a clone of the translation repository.
# - If a remote called 'english' exists, it points to the main Solidity repository.

script_dir="$(dirname "$0")"

function fail { >&2 echo -e "ERROR: $1"; exit 1; }

(( $# == 1 )) || fail "Wrong number of arguments\nUsage: $0 <release tag>"
TAG="$1"
if ! git config remote.english.url; then
    git remote add english "https://github.com/ethereum/solidity.git"
fi

git fetch english tag "$TAG" --no-tags
git fetch english develop

git checkout origin/develop
git checkout -b "sync-${TAG}"

today=$(date -u +%Y-%m-%d)
"${script_dir}/pull-and-resolve-english-changes.sh" "$TAG" "Sync with ethereum/solidity@${TAG} (${today})"
