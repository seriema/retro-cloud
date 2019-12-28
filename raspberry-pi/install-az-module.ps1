###################################
# Install the Azure PowerShell module 

# Install for the active user
Install-Module -Name Az -AllowClobber -Scope CurrentUser
# need to trust source: "PSGallery"

# Connect to Azure with a browser sign in token, if not already logged in
if ((Get-AzContext) -eq $null) {
    Connect-AzAccount
}
