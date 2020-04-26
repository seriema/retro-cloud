#!/bin/bash
# Pass in the resource group name as a parameter to recreate the '.retro-cloud.env' file. This is
# useful when starting a new RPi container during development and connecting to persistent resources.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

if [[ -z ${1:-} ]]; then
    echo "To recreate all the environment variables you need to pass the resource group name."
    exit 1
fi

envVarFile="$HOME/.retro-cloud.env"

echo "Starting recreating env vars with the resource group $1"
RETROCLOUD_AZ_RESOURCE_GROUP=$1

echo 'Fetch Azure details with the PowerShell Azure module'
RETROCLOUD_VM_IP=$(pwsh -NoLogo -NonInteractive -NoProfile -Command "(Get-AzPublicIpAddress -ResourceGroupName $RETROCLOUD_AZ_RESOURCE_GROUP).IpAddress")
RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME=$(pwsh -NoLogo -NonInteractive -NoProfile -Command "(Get-AzStorageAccount -ResourceGroupName $RETROCLOUD_AZ_RESOURCE_GROUP).StorageAccountName")

echo 'Recreate env vars based on assumptions that need to be updated manually if the setup scripts change'
RETROCLOUD_VM_USER="pi"
RETROCLOUD_VM_SHARE="/home/pi/retro-cloud-share"
RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS="/etc/smbcredentials/${RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME}.cred"
RETROCLOUD_AZ_FILE_SHARE_NAME="retro-cloud"
RETROCLOUD_AZ_FILE_SHARE_URL="//${RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME}.file.core.windows.net/retro-cloud"
RETROCLOUD_RPI_MOUNT_POINT="/mnt/${RETROCLOUD_AZ_RESOURCE_GROUP}"

# Recreate the env var file
echo "# RETRO-CLOUD: The environment variables below were not from a regular install. They were recreated by raspberry-pi/dev/recreate-env-var.sh" | sudo tee -a "$envVarFile"
echo "# These are mostly useful for troubleshooting." | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_AZ_RESOURCE_GROUP=${RETROCLOUD_AZ_RESOURCE_GROUP}" | sudo tee -a "$envVarFile"
echo "# These are needed by the RetroPie." | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_VM_IP=${RETROCLOUD_VM_IP}" | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_VM_USER=${RETROCLOUD_VM_USER}" | sudo tee -a "$envVarFile"
echo "# These are needed by both the RetroPie and VM." | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_VM_SHARE=${RETROCLOUD_VM_SHARE}" | sudo tee -a "$envVarFile"
echo "# These are needed by the VM." | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME=${RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME}" | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS=${RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS}" | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_AZ_FILE_SHARE_NAME=${RETROCLOUD_AZ_FILE_SHARE_NAME}" | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_AZ_FILE_SHARE_URL=${RETROCLOUD_AZ_FILE_SHARE_URL}" | sudo tee -a "$envVarFile"
echo "# RETRO-CLOUD: These are mostly useful for troubleshooting." | sudo tee -a "$envVarFile"
echo "export RETROCLOUD_RPI_MOUNT_POINT=${RETROCLOUD_RPI_MOUNT_POINT}" | sudo tee -a "$envVarFile"

echo 'Done.'
