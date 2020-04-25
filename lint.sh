#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'LINT: Check for Bash scripts without execute permission.'
./shared/validate-execute-permissions.sh

echo 'LINT: Lint with shellcheck.'
./shared/lint-shellcheck.sh

echo 'LINT: Done.'
