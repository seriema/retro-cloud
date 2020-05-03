# Verify that the ROM from test-copy-rom.sh shows up in the Azure File Share.

# Abort on error
$ErrorActionPreference = "Stop"

$storageAccountKey=((Get-AzStorageAccountKey -ResourceGroupName $Env:RETROCLOUD_AZ_RESOURCE_GROUP -Name $Env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME) | Where-Object {$_.KeyName -eq "key1"}).Value
$ctx = New-AzStorageContext -StorageAccountName $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME -StorageAccountKey $storageAccountKey

$target = "RetroPie/roms/nes/elite.zip"
"Attempt to download '$target'. The cmdlet will return an error if the file doesn't exist."
Get-AzStorageFileContent `
    -Context $ctx `
    -ShareName $env:RETROCLOUD_AZ_FILE_SHARE_NAME `
    -Path $target `
    -Verbose

# It didn't fail and error out, so it successed.
'Success. ROM found in Azure File Share.'

# Cleanup
Remove-Item .\elite.zip -Verbose
