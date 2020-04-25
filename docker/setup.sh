#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh

# Check if vars aren't already set, and prompt user if they want to reset (or quit).
if [[ -f .env ]]; then
    echo "You seem to have already run the development setup. Running it again will overwrite the .env file, that currently has these environment variables:"
    cat .env

    # https://stackoverflow.com/a/1885534
    read -p "Are you sure you want to reset [y/N]? " -r
    if [[ ! $REPLY =~ ^y|Y|[yY][eE][sS]$ ]]; then
        [[ "$0" = "${BASH_SOURCE[*]}" ]] && exit 1 || return 1
    fi

    # Remove the file so variables can be reset.
    rm .env
fi

echo
echo 'You will need to have the credentials for a Service Principal for this setup. It is not required to work with Retro-Cloud, but it is convenient when running the scripts a lot locally. Read more about it here https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-3.6.1'
echo "Note: You can create one by running 'raspberry-pi/dev/create-service-principal.ps1', or through the Azure portal."
echo

# Prompt the user for details.
read -p "Tenant ID: " -r
echo "AZURE_TENANT_ID=$REPLY" | tee -a .env > /dev/null

read -p "Application ID: " -r
echo "AZURE_SERVICE_PRINCIPAL_USER=$REPLY" | tee -a .env > /dev/null

read -p "Password: " -r
echo "AZURE_SERVICE_PRINCIPAL_SECRET=$REPLY" | tee -a .env > /dev/null

# Done.
echo
echo '.env file now configured.'
echo
