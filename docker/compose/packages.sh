#!/bin/bash

# Abort on error, error if variable is unset, error if any pipeline element fails, and print each command.
set -euox pipefail

echo 'Verify that apt-get is not broken due to wrong package sources, repo public keys, etc.'
# Added when apt-get would not update on Windows because there were Raspberry Pi Foundation apt-get
# sources expecting arm32, and when not having the right public keys validating those sources.
[[ $(sudo apt-get update) ]]
