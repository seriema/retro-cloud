#!/bin/bash
# shellcheck disable=SC1091
source /etc/profile.d/retro-cloud-dev.sh

# Abort on error, and error if variable is unset
set -eu

# Check if vars aren't already sent, and prompt user if they want to reset (or quit).
if [ -n "${RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET:-}" ]; then
    echo "You seem to have already run the development setup. Running it again will overwrite these environment variables:"
    echo "Tenant ID: $RC_DEV_AZURE_TENANT_ID"
    echo "Application ID: $RC_DEV_AZURE_SERVICE_PRINCIPAL_USER"
    echo "Password: $RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET"

    # https://stackoverflow.com/a/1885534
    read -p "Are you sure you want to reset [y/N]? " -r
    if [[ ! $REPLY =~ ^y|Y|[yY][eE][sS]$ ]]; then
        [[ "$0" = "${BASH_SOURCE[*]}" ]] && exit 1 || return 1
    fi

    # Remove the file so variables can be reset.
    sudo rm /etc/profile.d/retro-cloud-dev.sh
fi

echo
echo 'You will need to have the credentials for a Service Principal for this setup. It is not required to work with Retro-Cloud, but it is convenient when running the scripts a lot locally. Read more about it here https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-3.6.1'
echo "Note: You can create one by running 'raspberry-pi/dev/create-service-principal.ps1', or through the Azure portal."
echo

# Add header to file.
echo '# RETRO-CLOUD: The environment variables below were set by the retro-cloud developer setup script.' | sudo tee -a /etc/profile.d/retro-cloud-dev.sh > /dev/null

# Prompt the user for details.
read -p "Tenant ID: " -r
echo "export RC_DEV_AZURE_TENANT_ID=$REPLY" | sudo tee -a /etc/profile.d/retro-cloud-dev.sh > /dev/null

read -p "Application ID: " -r
echo "export RC_DEV_AZURE_SERVICE_PRINCIPAL_USER=$REPLY" | sudo tee -a /etc/profile.d/retro-cloud-dev.sh > /dev/null

read -p "Password: " -r
echo "export RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET=$REPLY" | sudo tee -a /etc/profile.d/retro-cloud-dev.sh > /dev/null

# Done.
echo
echo 'Now run "source /etc/profile.d/retro-cloud-dev.sh" to load the environment variables in this shell.'
echo
