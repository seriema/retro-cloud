#!/bin/bash
# Take a parameter for what path to list. Defaults to the users home.
path=${1:-"$HOME"}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

sudo find "$path" | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
