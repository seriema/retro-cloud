# Verify that the ROM from test-copy-rom.sh shows up in the Azure File Share.

# Abort on error
$ErrorActionPreference = "Stop"

$ctx = New-AzStorageContext -StorageAccountName $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME -StorageAccountKey $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY

# Attempt to download the file. The cmdlet will return an error if the file doesn't exist.
Get-AzStorageFileContent `
    -Context $ctx `
    -ShareName $env:RETROCLOUD_AZ_FILE_SHARE_NAME `
    -Path "RetroPie/roms/nes/elite.zip" `
    -Verbose

# It didn't fail and error out, so it successed.
'Success. ROM found in Azure File Share.'

# Cleanup
Remove-Item .\elite.zip -Verbose
