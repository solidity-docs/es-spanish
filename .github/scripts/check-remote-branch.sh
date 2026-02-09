#!/bin/bash
set -euo pipefail

function fail { >&2 echo -e "ERROR: $1"; exit 1; }

(( $# == 1 )) || fail "Wrong number of arguments\nUsage: $0 <translation repo branch"
BRANCH="$1"

# check if branch exists
if git ls-remote --exit-code --heads origin "$BRANCH"
then
    branch_exists=true
    echo "Branch ${BRANCH} already exists"
else
    branch_exists=false
    echo "Branch ${BRANCH} does not exist"
fi

echo "branch_exists=$branch_exists" >> "$GITHUB_OUTPUT"
