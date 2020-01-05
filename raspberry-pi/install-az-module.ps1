# Abort on error
$ErrorActionPreference = "Stop"

###################################
# Install the Azure PowerShell module

'Install AZ for the active user, if not already installed.'
if ((Get-Module -ListAvailable -Name Az) -eq $null) {
    # The -Force parameter is needed to avoid a user prompt, but requires the if-installed check otherwise it reinstalls which takes time.
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force > $null
}

'Connect to Azure with a browser sign in token, if not already logged in.'
# Note: user prompt!
if ((Get-AzContext) -eq $null) {
    Connect-AzAccount
}
