<#
    .SYNOPSIS
    Create an Azure Service Principal. Used for CI/CD and automation.

    .EXAMPLE
    create-service-principal "a1c2e3g4-1a2b-a3c4-1234-abcdefghijkl"
#>

Param(
    [Parameter(Mandatory = $True)]
    [string]$subscriptionId,

    [string]$displayName = "continous-integration"
)

# Abort on error
$ErrorActionPreference = "Stop"

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

'Setting environment variables (those above in caps).'
$Env:AZURE_TENANT_ID                = $servicePrincipal.AZURE_TENANT_ID
$Env:AZURE_SERVICE_PRINCIPAL_USER   = $servicePrincipal.AZURE_SERVICE_PRINCIPAL_USER
$Env:AZURE_SERVICE_PRINCIPAL_SECRET = $servicePrincipal.AZURE_SERVICE_PRINCIPAL_SECRET

'Done.'
