#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

bash -i ssh-vm.sh "./run-skyscraper.sh"
