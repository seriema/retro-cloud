#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'LINT: Check for Bash scripts without execute permission.'
./shared/validate-execute-permissions.sh

echo 'LINT: Lint with shellcheck.'
./shared/lint-shellcheck.sh

echo 'LINT: Done.'
