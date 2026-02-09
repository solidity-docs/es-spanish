#!/bin/bash
set -euo pipefail

CONFIG_FILE="$1"

function load_option {
    local option="$1"
    local default="$2"

    if [[ ! -e $CONFIG_FILE ]]; then
        echo "$default"
        return 0
    fi

    # We want single-line output to be able to easily pass it to $GITHUB_OUTPUT
    local value
    value=$(jq --compact-output ".${option}" "$CONFIG_FILE")

    if [[ $value == null ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

function validate_boolean {
    local option="$1"
    local value="$2"

    if [[ $value != true && $value != false ]]; then
        >&2 echo "${CONFIG_FILE}: Invalid option value for '${option}'. Expected 'true' or 'false', got '${value}'."
        return 1
    fi
}

function validate_list {
    local option="$1"
    local value="$2"

    if ! echo "$value" | jq > /dev/null 2>&1; then
        >&2 echo "${CONFIG_FILE}: Invalid option value for '${option}'. Expected a JSON list, got '${value}'."
        return 1
    fi
}

function print_option {
    local option="$1"
    local value="$2"

    # The second echo is there so that we can actually see the value in the log for debug purposes
    echo "${option}=${value}" >> "$GITHUB_OUTPUT"
    echo "${option}: ${value}"
}

# NOTE: If you change defaults here, remember to update the README
bot_disabled=$(load_option custom_sync_disabled true)
randomly_assign_maintainers=$(load_option randomly_assign_maintainers false)
pr_labels=$(load_option pr_labels '["sync-pr"]')

validate_boolean disabled "$bot_disabled"
validate_boolean randomly_assign_maintainers "$randomly_assign_maintainers"
validate_list pr_labels "$pr_labels"

print_option bot_disabled "$bot_disabled"
print_option randomly_assign_maintainers "$randomly_assign_maintainers"
print_option pr_labels "$pr_labels"
