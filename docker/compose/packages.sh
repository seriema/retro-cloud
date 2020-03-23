#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'Verify that apt-get is not broken'
[[ $(sudo apt-get update) ]]
