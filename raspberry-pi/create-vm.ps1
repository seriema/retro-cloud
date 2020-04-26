# Take a parameter for prefixing the resource group name. It default to the current date to be unique
# yet findable. Useful values could be the build number during CI, or the users unique machine name.
param (
    [string]$rgPrefix = [NullString]::Value
)

# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell

# Abort on error
$ErrorActionPreference = "Stop"

# Enable debug output
$DebugPreference = "Continue"

# Count all the uses of "ProgressHelper" in this script to calculate the progress %.
$script:progressStepCount = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'ProgressHelper' }).Count
$script:progressStep = 0

function ProgressHelper {
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory=$True)]
      [string]$activity,

      [Parameter(Mandatory=$True)]
      [string]$operation
  )

  $script:progressStep++;
  $percent = (100 * $script:progressStep) / $script:progressStepCount;
  Write-Host "-Activity $activity -Status $operation -PercentComplete $percent"
}

# Shared variables
# If no prefix was passed as a parameter to the script, default to the current date.
if ([String]::IsNullOrEmpty($rgPrefix)) {
    $rgPrefix = Get-Date -Format "yyyy-MM-dd__HH.mm.ss__"
}
$rg = "$($rgPrefix)__retro-cloud"
$loc = "EastUS"
$envVarFile="$HOME/.retro-cloud.env"

####################################
$currentActivity = "Prerequisites"

ProgressHelper $currentActivity "Checking for an existing SSH public key in ~/.ssh/id_rsa.pub"
if (![System.IO.File]::Exists("$HOME/.ssh/id_rsa.pub")) {
  ProgressHelper $currentActivity "No SSH key found. Creating without passphrase."
  ssh-keygen -t rsa -b 2048 -f "$HOME/.ssh/id_rsa" -N '""'
}
# Only take the first line in id_rsa.pub as newlines will cause $sshPublicKey to become an array.
$sshPublicKey = cat "$HOME/.ssh/id_rsa.pub" | head -n 1
if (!$sshPublicKey) {
    Write-Error "SSH public key is empty";
}
$sshPublicKey | Format-Table

ProgressHelper $currentActivity "Saving the Azure Resource Group name locally in $envVarFile in case of failure during setup"
Add-Content "$envVarFile" '# RETRO-CLOUD: The environment variables below are from raspberry-pi/create-vm.ps1'
Add-Content "$envVarFile" '# These are mostly useful for troubleshooting.'
Add-Content "$envVarFile" "export RETROCLOUD_AZ_RESOURCE_GROUP=$rg"

####################################
$currentActivity = "Initializing"

ProgressHelper $currentActivity "Creating a resource group"
New-AzResourceGroup `
  -Name $rg `
  -Location $loc `
| Format-Table

####################################
$currentActivity = "Create virtual network resources"

ProgressHelper $currentActivity "Creating a subnet configuration"
# We will have to surpress the breaking change message from New-AzVirtualNetworkSubnetConfig due to https://stackoverflow.com/questions/59315846/powershell-azure-new-azvirtualnetworksubnetconfig-breaking-changes
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "subnet" `
  -AddressPrefix 192.168.1.0/24
$subnetConfig | Format-Table
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "false"

ProgressHelper $currentActivity "Creating a virtual network"
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "vnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig
$vnet | Format-Table

ProgressHelper $currentActivity "Creating a public IP address and specifying a DNS name"
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $rg `
  -Location $loc `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "publicdns$(Get-Random)"
$pip | Format-Table
$ip=$pip.IpAddress

ProgressHelper $currentActivity "Creating an inbound network security group rule for port 22 (SSH)"
$nsgRuleSSH = New-AzNetworkSecurityRuleConfig `
  -Name "networkSecurityGroupRuleSSH"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1000 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 22 `
  -Access "Allow"
$nsgRuleSSH | Format-Table

ProgressHelper $currentActivity "Creating an inbound network security group rule for port 80 (web)"
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
  -Name "networkSecurityGroupRuleWWW" `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"
$nsgRuleWeb | Format-Table

ProgressHelper $currentActivity "Creating a network security group (NSG)"
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "networkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb
$nsg | Format-Table

ProgressHelper $currentActivity "Creating a virtual network card and associate it with the public IP address and NSG"
$nic = New-AzNetworkInterface `
  -Name "nic" `
  -ResourceGroupName $rg  `
  -Location $loc `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id
$nic | Format-Table

###################################
$currentActivity = "Create the storage account (for scraping cache and boot diagnostics)"

# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
$storageAccountName = ("$($rgPrefix)storage" -replace '[^A-Za-z0-9]+', '').ToLower()

ProgressHelper $currentActivity "Creating the storage account"
$storageAccount = New-AzStorageAccount `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name $storageAccountName `
  -SkuName "Standard_LRS"
$storageAccount | Format-Table
# There has to be a better way to get the key without calling Get-AzStorageAccount (commented out version below)?
$storageAccountKey = ($storageAccount.Context.ConnectionString -split ";" | Select-String -Pattern 'AccountKey=' -SimpleMatch).Line.Replace('AccountKey=','')
# $storageAccountKey = ((Get-AzStorageAccountKey -ResourceGroupName $rg -Name $storageAccountName) | Where-Object {$_.KeyName -eq "key1"}).Value
$storageAccountKey | Format-Table

# TODO: Use the same share for ROMs for now.
ProgressHelper $currentActivity "Creating the Azure File Share"
$fileShareName = "retro-cloud"
$fileShare = New-AzStorageShare `
   -Name $fileShareName  `
   -Context $storageAccount.Context
$fileShare | Format-Table
$smbPath = $fileShare.Uri.AbsoluteUri.split(":")[1] #Remove the "https" part of the url so the path is as "//storageAccountName.file.core.windows.net/fileShareName"

###################################
$currentActivity = "Create the virtual machine"

ProgressHelper $currentActivity "Defining the credential object"
$username = "pi"
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

if ($Env:CI) {
    $vmSizeMessage="a fast and expensive VM for Continous Integration"
    $vmSize="Standard_F1s"
} else {
    $vmSizeMessage="a cheap VM for the user to save money (can be upscaled in the Azure Portal)"
    $vmSize="Standard_B1s"
}

ProgressHelper $currentActivity "Creating the virtual machine configuration with $vmSizeMessage"
$vmName = "VM"
$vmConfig = `
  New-AzVMConfig `
    -VMName $vmName `
    -VMSize $vmSize | `
  Set-AzVMOperatingSystem `
    -Linux `
    -ComputerName $vmName `
    -Credential $cred `
    -DisablePasswordAuthentication | `
  Set-AzVMSourceImage `
    -PublisherName "Canonical" `
    -Offer "UbuntuServer" `
    -Skus "18.04-LTS" `
    -Version "latest" | `
  Add-AzVMNetworkInterface `
    -Id $nic.Id | `
  Set-AzVMBootDiagnostic `
    -Enable -ResourceGroupName $rg `
    -StorageAccountName $storageAccountName
$vmConfig | Format-Table

ProgressHelper $currentActivity "Adding the SSH public key to the VM's SSH authorized keys"
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/$username/.ssh/authorized_keys" `
| Format-Table

ProgressHelper $currentActivity "Creating the virtual machine (takes a while)"
New-AzVM `
  -ResourceGroupName $rg `
  -Location $loc `
  -VM $vmConfig `
| Format-Table

###################################
$currentActivity = "Setup the virtual machine"

ProgressHelper $currentActivity "Waiting for the VM to boot up"
# TODO: There has to be a better way. Perhaps Azure Boot Diagnostics?
$sshStatus = $null
$ErrorActionPreference = "SilentlyContinue"
while ($sshStatus -eq $null) {
  $sshStatus = ssh-keyscan -H $ip 2>&1 $null
}
$ErrorActionPreference = "Stop"

ProgressHelper $currentActivity "Adding fingerprint to ~/.ssh/known_hosts"
# Avoids prompts when connecting later. (https://serverfault.com/a/316100)
# First, remove the key from known hosts. If it doesn't exist it exits with an error message, that can be ignored. If it succeeds it outputs what lines were found, which can also be ignored.
# Disabled for now because the error, even when piped, will stop the script due to ErrorActionPreference
# ssh-keygen -R $ip *> $null
# Second, add the fingerprint to known hosts, and ignore the status message (that's outputed to stderr).
# TODO: How do I silence ssh-keygen?! "| Out-Null", "*> $null", "2> $null", "2>&1 $null", none of them work. Somehow stderr and stdout gets by.
$ErrorActionPreference = "SilentlyContinue"
ssh-keyscan -H $ip >> "$HOME/.ssh/known_hosts" 2>&1 $null
$ErrorActionPreference = "Stop"

ProgressHelper $currentActivity "Creating a folder to be shared with the Raspberry Pi"
# Creating it from the rpi so the setup.sh can continue by mounting it.
$sharePath="/home/$username/retro-cloud-share"
ssh "$($username)@$ip" "mkdir -p $sharePath"

ProgressHelper $currentActivity "Creating a credential file to store the username and password for the Azure File Share"
# This is part of mounting a file share on Linux, that is done by virtual-machine/mount-az-share.sh,
# but by doing it here we only need to pass the storage account key once and avoid it being stored in
# the environment variables with the other resource values (which we pass around and print for debugging).
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#create-a-persistent-mount-point-for-the-azure-file-share-with-etcfstab

$smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
ssh "${username}@${ip}" "sudo mkdir -p /etc/smbcredentials"
ssh "${username}@${ip}" "echo 'username=$storageAccountName' | sudo tee $smbCredentialFile > /dev/null"
ssh "${username}@${ip}" "echo 'password=$storageAccountKey' | sudo tee -a $smbCredentialFile > /dev/null"
# Change permissions on the credential file so only root can read or modify the password file
ssh "${username}@${ip}" "sudo chmod 600 $smbCredentialFile"

###################################
$currentActivity = "Persist resource values"

$envVarFile="$HOME/.retro-cloud.env"
ProgressHelper $currentActivity "Saving configuration variables locally in $envVarFile"

Add-Content "$envVarFile" '# These are needed by the RetroPie.'
Add-Content "$envVarFile" "export RETROCLOUD_VM_IP=$ip"
Add-Content "$envVarFile" "export RETROCLOUD_VM_USER=$username"
Add-Content "$envVarFile" '# These are needed by both the RetroPie and VM.'
Add-Content "$envVarFile" "export RETROCLOUD_VM_SHARE=$sharePath"
Add-Content "$envVarFile" '# These are needed by the VM.'
Add-Content "$envVarFile" "export RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME=$storageAccountName"
Add-Content "$envVarFile" "export RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS=$smbCredentialFile"
Add-Content "$envVarFile" "export RETROCLOUD_AZ_FILE_SHARE_NAME=$fileShareName"
Add-Content "$envVarFile" "export RETROCLOUD_AZ_FILE_SHARE_URL=$smbPath"

ProgressHelper $currentActivity "Add $envVarFile to be loaded by ~/.bashrc"
Add-Content "$HOME/.bashrc" ""
Add-Content "$HOME/.bashrc" "# RETRO-CLOUD CONFIG START"
Add-Content "$HOME/.bashrc" ". $envVarFile"
Add-Content "$HOME/.bashrc" "# RETRO-CLOUD CONFIG END"

$vmEnvVarFile="/home/$username/.retro-cloud.env"
ProgressHelper $currentActivity "Passing configuration variables to VM (${username}@${ip}:${vmEnvVarFile})"
scp "$envVarFile" "${username}@${ip}:${vmEnvVarFile}"
ssh "${username}@${ip}" "echo '' | sudo tee -a ~/.bashrc > /dev/null"
ssh "${username}@${ip}" "echo '# RETRO-CLOUD CONFIG START' | sudo tee -a ~/.bashrc > /dev/null"
ssh "${username}@${ip}" "echo '. $vmEnvVarFile' | sudo tee -a ~/.bashrc > /dev/null"
ssh "${username}@${ip}" "echo '# RETRO-CLOUD CONFIG END' | sudo tee -a ~/.bashrc > /dev/null"

ProgressHelper "Done" " "

"The Azure resource group (see it in https://portal.azure.com/): '$rg'"
"VM is accessible with: ssh $($username)@$ip"
"Continue setup in the VM. See the Readme."
