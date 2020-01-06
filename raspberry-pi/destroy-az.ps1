$continue = Read-Host "This will destroy everything, including ROMs, in the Azure resource group '$env:RETROCLOUD_AZ_RESOURCE_GROUP'. Are you sure? (y/N)"

if ($continue.ToLower() -eq 'y') {
    Remove-AzResourceGroup $env:RETROCLOUD_AZ_RESOURCE_GROUP -y
}
