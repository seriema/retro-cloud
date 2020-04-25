#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

sudo find "$HOME" | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
