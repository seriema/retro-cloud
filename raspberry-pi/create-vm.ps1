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
$prefix = Get-Date -Format "yyyy-MM-dd__HH.mm.ss__"
$rg = "$($prefix)retro-cloud"
$loc = "EastUS"

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
$storageAccountName = ("$($prefix)storage" -replace '[^A-Za-z0-9]+', '').ToLower()

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
ProgressHelper $currentActivity "Creating the file share"
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

ProgressHelper $currentActivity "Creating the virtual machine configuration"
$vmName = "VM"
$vmConfig = `
  New-AzVMConfig `
    -VMName $vmName `
    -VMSize "Standard_B2s" | `
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

ProgressHelper $currentActivity "Checking for an existing SSH public key in /home/pi/.ssh/id_rsa.pub"
if (![System.IO.File]::Exists("/home/pi/.ssh/id_rsa.pub")) {
  ProgressHelper $currentActivity "No SSH key found. Creating without passphrase."
  ssh-keygen -t rsa -b 2048 -f /home/pi/.ssh/id_rsa -N '""' -q
}

ProgressHelper $currentActivity "Adding the SSH public key to the VM's SSH authorized keys"
# Only take the first line in id_rsa.pub as newlines will cause $sshPublicKey to become an array.
$sshPublicKey = cat /home/pi/.ssh/id_rsa.pub | head -n 1
$sshPublicKey | Format-Table
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

###################################
$currentActivity = "Persist resource values"

ProgressHelper $currentActivity "Saving configuration variables locally (~/.bashrc)"
Add-Content "$HOME/.bashrc" ""
Add-Content "$HOME/.bashrc" '# RETRO-CLOUD: The environment variables below were set by the retro-cloud setup script.'
Add-Content "$HOME/.bashrc" "export RETROCLOUD_VM_IP=$ip"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_VM_USER=$username"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_VM_SHARE=$sharePath"
Add-Content "$HOME/.bashrc" '# RETRO-CLOUD: These are mostly useful for troubleshooting.'
Add-Content "$HOME/.bashrc" "export RETROCLOUD_AZ_RESOURCE_GROUP=$rg"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME=$storageAccountName"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY=$storageAccountKey"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_AZ_FILE_SHARE_NAME=$fileShareName"
Add-Content "$HOME/.bashrc" "export RETROCLOUD_AZ_FILE_SHARE_URL=$smbPath"

ProgressHelper $currentActivity "Passing configuration variables to VM ($username@${ip}:/home/$username/.bashrc)"
ssh "$($username)@$ip" "echo '' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo '# RETRO-CLOUD: The environment variables below were set by the retro-cloud setup script.' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export resourceGroupName=$rg' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export storageAccountName=$storageAccountName' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export storageAccountKey=$storageAccountKey' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export fileShareName=$fileShareName' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export smbPath=$smbPath' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$ip" "echo 'export RETROCLOUD_VM_SHARE=$sharePath' | sudo tee -a ~/.bashrc > /dev/null"

ProgressHelper "Done" " "

"The Azure resource group (see it in https://portal.azure.com/): '$rg'"
"VM is accessible with: ssh $($username)@$ip"
"Continue setup in the VM. See the Readme."
