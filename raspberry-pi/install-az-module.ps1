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
