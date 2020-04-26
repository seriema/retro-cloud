# Take a parameter for prefixing the Azure resource group name. This is useful when you want to
# destroy a resource group that was created outside of the scripts during development, or in CI
# when the resource group prefix is predictable and the teardown can happen in a context (such as a
# separate container) without '.retro-cloud.env' available.
param (
    [string]$rgPrefix = [NullString]::Value
)

# Can run without prompting if the following environment variables are set:
# * AZURE_SERVICE_PRINCIPAL_SECRET

# Abort on error
$ErrorActionPreference = "Stop"

# Enable debug output
$DebugPreference = "Continue"

# If no parameter was given, use what should be available during a normal installation.
if ([String]::IsNullOrEmpty($rgPrefix)) {
    $resourceGroup = $env:RETROCLOUD_AZ_RESOURCE_GROUP
}
# When a parameter is given, use the same naming convention as create-vm.ps1
else {
    $resourceGroup = "$($rgPrefix)__retro-cloud"
}

"Delete Azure resource group $resourceGroup ..."
if (!$env:AZURE_SERVICE_PRINCIPAL_SECRET) {
    '... Note: This operation takes a very long time (15-20 min) so it will only send a command to Azure and not wait for the removal to be complete.'

    $title    = 'WARNING! You will lose all your ROMs and metadata!'
    $question = 'Are you sure you want to proceed?'
    $choices  = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Remove-AzResourceGroup -Name $resourceGroup -AsJob
    } else {
        Write-Host 'Cancelled.'
    }
} else {
    '... assuming automation with Service Principle. Do not wait for resources to be deleted.'
    Remove-AzResourceGroup -Name $resourceGroup -Force -AsJob
}
