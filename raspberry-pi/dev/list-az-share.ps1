# Abort on error
$ErrorActionPreference = "Stop"

Function GetFiles($parent)
{
    $cloud = $parent | Get-AzStorageFile
    $directories = $cloud | Where-Object {$_.GetType().Name -eq "CloudFileDirectory"}
    $files = $cloud | Where-Object {$_.GetType().Name -eq "CloudFile"}

    foreach ($directory in $directories) {
        GetFiles($directory)
    }

    foreach ($file in $files) {
        $file.Uri.LocalPath
    }
}

$ctx = New-AzStorageContext -StorageAccountName $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME -StorageAccountKey $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY
$root = Get-AzStorageFile -Context $ctx -ShareName $env:RETROCLOUD_AZ_FILE_SHARE_NAME

GetFiles($root)
