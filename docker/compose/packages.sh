#!/bin/bash

# Abort on error, error if variable is unset, and enable debug output
set -eux

echo 'Verify that apt-get is not broken'
[[ $(sudo apt-get update) ]]
