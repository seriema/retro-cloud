# Abort on error
$ErrorActionPreference = "Stop"

Function GetFiles($parent)
{
    $cloud = $parent | Get-AzStorageFile
    $directories = $cloud | Where-Object {$_.GetType().Name -eq "AzureStorageFileDirectory"}
    $files = $cloud | Where-Object {$_.GetType().Name -eq "AzureStorageFile"}

    foreach ($directory in $directories) {
        GetFiles($directory)
    }

    foreach ($file in $files) {
        $file.CloudFile.Uri.LocalPath
    }
}

$storageAccountKey=((Get-AzStorageAccountKey -ResourceGroupName $Env:RETROCLOUD_AZ_RESOURCE_GROUP -Name $Env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME) | Where-Object {$_.KeyName -eq "key1"}).Value
$ctx = New-AzStorageContext -StorageAccountName $env:RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME -StorageAccountKey $storageAccountKey
$root = Get-AzStorageFile -Context $ctx -ShareName $env:RETROCLOUD_AZ_FILE_SHARE_NAME

GetFiles($root)
