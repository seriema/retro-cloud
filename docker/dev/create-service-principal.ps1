<#
    .SYNOPSIS
    Create an Azure Service Principal. Used for CI/CD and automation.

    .EXAMPLE
    create-service-principal "a1c2e3g4-1a2b-a3c4-1234-abcdefghijkl"
#>

Param(
    [Parameter(Mandatory = $True)]
    [string]$subscriptionId,

    [string]$displayName = "retro-cloud-sp-for-$(hostname)"
)

# Abort on error
$ErrorActionPreference = "Stop"

'This will create a Service Principal. It is not required to work with Retro-Cloud, but it is convenient when manually running the scripts multiple times.'
'Read more about Service Principals here https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-3.6.1'

# It searches in the work directory.
if ([System.IO.File]::Exists(".env")) {
    ''
    'You seem to already have an .env file. Running this script will overwrite these variables:'
    ''
    Get-Content "../../.env"
    ''
    $decision = $Host.UI.PromptForChoice('', 'Are you sure you want to proceed?', ( '&Yes', '&No' ), 1)
    if ($decision -ne 0) {
        exit
    }
}

Set-AzContext -SubscriptionId $subscriptionId

$sp = New-AzADServicePrincipal -DisplayName $displayName -Verbose

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$servicePrincipal = [PSCustomObject]@{
    'Subscription ID'                = $subscriptionId
    'AZURE_TENANT_ID'                = (Get-AzContext).Tenant.Id
    'AZURE_SERVICE_PRINCIPAL_USER'   = $sp.ApplicationId.Guid
    'AZURE_SERVICE_PRINCIPAL_SECRET' = $UnsecureSecret
    'User name'                      = $sp.DisplayName
    'User ID'                        = $sp.Id
}

# Print the data
$servicePrincipal

# Save the data
$servicePrincipal | Out-File -FilePath ../../.env
"AZURE_TENANT_ID=$($servicePrincipal.AZURE_TENANT_ID)" | Out-File -FilePath ../../.env
"AZURE_SERVICE_PRINCIPAL_USER=$($servicePrincipal.AZURE_SERVICE_PRINCIPAL_USER)" | Out-File -FilePath ../../.env -Append
"AZURE_SERVICE_PRINCIPAL_SECRET=$($servicePrincipal.AZURE_SERVICE_PRINCIPAL_SECRET)" | Out-File -FilePath ../../.env -Append

''
'Stored as .env in the root.'
''
'Done.'
