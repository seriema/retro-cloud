#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# The VM script handles validation and to avoid duplication we just send empty strings if the user forgets an argument
module=${1:-""}
user=${2:-""}
password=${3:-""}

echo "Adding $module credential for $user with $password on the VM."

bash -i ssh-vm.sh "./add-scraper-credential.sh $module $user $password"
