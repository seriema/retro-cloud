# Can run without prompting if the following environment variables are set:
# * AZURE_SERVICE_PRINCIPAL_SECRET

# Abort on error
$ErrorActionPreference = "Stop"

# Enable debug output
$DebugPreference = "Continue"

'Delete resources from Azure ...'
if (!$env:AZURE_SERVICE_PRINCIPAL_SECRET) {
    '... are you sure?'
    # Note: user prompt!
    Remove-AzResourceGroup -Name $env:RETROCLOUD_AZ_RESOURCE_GROUP
} else {
    '... assuming automation with Service Principle. Do not wait for resources to be deleted.'
    Remove-AzResourceGroup -Name $env:RETROCLOUD_AZ_RESOURCE_GROUP -Force -AsJob
}
