# Can run without prompting if the following environment variables are set:
# * AZURE_SERVICE_PRINCIPAL_SECRET
# * AZURE_SERVICE_PRINCIPAL_USER
# * AZURE_TENANT_ID

# Abort on error
$ErrorActionPreference = "Stop"

###################################
# Install the Azure PowerShell module

'Install the Azure module for PowerShell ...'
if ((Get-Module -ListAvailable -Name Az) -eq $null) {
    '...for the active user.'
    # The -Force parameter is needed to avoid a user prompt, but requires the if-installed check otherwise it reinstalls which takes time.
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force
} else {
    '...is not needed. Already installed.'
}

'Log in to Azure ...'
if ((Get-AzContext) -eq $null) {
    # If there's no env var then prompt the user
    if (!$env:AZURE_SERVICE_PRINCIPAL_SECRET) {
        '...with a browser sign in token.'
        # Note: user prompt!
        Connect-AzAccount
    } else {
        '...with a Service Principle using environment variables.'
        $passwd = ConvertTo-SecureString $env:AZURE_SERVICE_PRINCIPAL_SECRET -AsPlainText -Force
        $pscredential = New-Object System.Management.Automation.PSCredential($env:AZURE_SERVICE_PRINCIPAL_USER, $passwd)
        Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $env:AZURE_TENANT_ID
    }
} else {
    '...already logged in.'
}
