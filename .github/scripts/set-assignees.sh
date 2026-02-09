#!/bin/bash
set -euo pipefail
LANGUAGE=$1

# extracts de from de-german
lang_code=${LANGUAGE:0:2}
number_of_maintainers=$(jq '.maintainers | length' ".github-workflow/langs/$lang_code.json")


assignee=$((($RANDOM%$number_of_maintainers)))
reviewer=$((($RANDOM%$number_of_maintainers)))

while [[ $assignee == "$reviewer" && number_of_maintainers -gt 1 ]]
do
    reviewer=$((($RANDOM%$number_of_maintainers)))
done

echo "reviewer=$(
    jq --raw-output ".maintainers[$reviewer]" ".github-workflow/langs/$lang_code.json"
)" >> $GITHUB_ENV

echo "assignee=$(
    jq --raw-output ".maintainers[$assignee]" ".github-workflow/langs/$lang_code.json"
)" >> $GITHUB_ENV

