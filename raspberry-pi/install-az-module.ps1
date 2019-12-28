###################################
# Install the Azure PowerShell module

# Install for the active user, if not already installed.
# Note: The -Force parameter is needed to avoid a user prompt, but also does a reinstall if already installed.
Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

# Connect to Azure with a browser sign in token, if not already logged in.
# Note: user prompt!
if ((Get-AzContext) -eq $null) {
    Connect-AzAccount
}
