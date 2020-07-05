#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

bash -i ssh-vm.sh "./run-skyscraper.sh"
