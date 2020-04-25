# Can run without prompting if the following environment variables are set:
# * AZURE_SERVICE_PRINCIPAL_SECRET

# Do not stop on error
$ErrorActionPreference = "Continue"

# Enable debug output
$DebugPreference = "Continue"

'Delete resources from Azure ...'
if (!$env:AZURE_SERVICE_PRINCIPAL_SECRET) {
    '... Note: This operation takes a very long time (15-20 min) so it will only send a command to Azure and not wait for the removal to be complete.'

    $title    = 'WARNING! You will lose all your ROMs and metadata!'
    $question = 'Are you sure you want to proceed?'
    $choices  = '&Yes', '&No'
    $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
    if ($decision -eq 0) {
        Remove-AzResourceGroup -Name $env:RETROCLOUD_AZ_RESOURCE_GROUP -AsJob
    } else {
        Write-Host 'Cancelled.'
    }
} else {
    '... assuming automation with Service Principle. Do not wait for resources to be deleted.'
    Remove-AzResourceGroup -Name $env:RETROCLOUD_AZ_RESOURCE_GROUP -Force -AsJob
}
