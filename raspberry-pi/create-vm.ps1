# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell

# Don't create new resources if there's an error
$ErrorActionPreference = "Stop"

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
  Write-Progress -Activity $activity -Status $operation -PercentComplete $percent;
}

# Shared variables
$prefix = Get-Date -Format "M-d_HH-mm-ss_"
$rg = "$($prefix)retro-cloud-test"
$loc = "EastUS"

####################################
$currentActivity = "Initializing"

ProgressHelper $currentActivity "Creating a resource group"
New-AzResourceGroup `
  -Name $rg `
  -Location $loc `
> $null

####################################
$currentActivity = "Create virtual network resources"

ProgressHelper $currentActivity "Creating a subnet configuration"
# We will have to surpress the breaking change message from New-AzVirtualNetworkSubnetConfig due to https://stackoverflow.com/questions/59315846/powershell-azure-new-azvirtualnetworksubnetconfig-breaking-changes
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "subnet" `
  -AddressPrefix 192.168.1.0/24
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "false"

ProgressHelper $currentActivity "Creating a virtual network"
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "vnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

ProgressHelper $currentActivity "Creating a public IP address and specifying a DNS name"
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $rg `
  -Location $loc `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "publicdns$(Get-Random)"

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


ProgressHelper $currentActivity "Creating an inbound network security group rule for port 80 (web)"
$nsgRuleWeb = New-AzNetworkSecurityRuleConfig `
  -Name "networkSecurityGroupRuleWWW"  `
  -Protocol "Tcp" `
  -Direction "Inbound" `
  -Priority 1001 `
  -SourceAddressPrefix * `
  -SourcePortRange * `
  -DestinationAddressPrefix * `
  -DestinationPortRange 80 `
  -Access "Allow"

ProgressHelper $currentActivity "Creating a network security group (NSG)"
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "networkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb

ProgressHelper $currentActivity "Creating a virtual network card and associate it with the public IP address and NSG"
$nic = New-AzNetworkInterface `
  -Name "nic" `
  -ResourceGroupName $rg  `
  -Location $loc `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

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
# There has to be a better way to get the key without calling Get-AzStorageAccount (commented out version below)?
$storageAccountKey = ($storageAccount.Context.ConnectionString -split ";" | Select-String -Pattern 'AccountKey').Line.split("=")[1]
# $storageAccountKey = ((Get-AzStorageAccountKey -ResourceGroupName $rg -Name $storageAccountName) | Where-Object {$_.KeyName -eq "key1"}).Value

ProgressHelper $currentActivity "Creating the file share (for the scraping cache)"
$fileShareName = "skyscraper-cache"
$fileShare = New-AzStorageShare `
   -Name $fileShareName  `
   -Context $storageAccount.Context
$smbPath = $fileShare.Uri.AbsoluteUri.split(":")[1] #Remove the "https" part of the url so the path is as "//storageAccountName.file.core.windows.net/skyscraper-cache"

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
    -VMSize "Standard_D1" | `
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

ProgressHelper $currentActivity "Checking for an existing SSH public key, otherwise creating one"
if (![System.IO.File]::Exists("/home/pi/.ssh/id_rsa.pub")) {
  ssh-keygen -t rsa -b 2048 -f /home/pi/.ssh/id_rsa -N '' -q
}

ProgressHelper $currentActivity "Adding the SSH public key to the VM's SSH authorized keys"
# Only take the first line in id_rsa.pub as newlines will cause $sshPublicKey to become an array.
$sshPublicKey = cat ~/.ssh/id_rsa.pub | head -n 1
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/$username/.ssh/authorized_keys" `
> $null

ProgressHelper $currentActivity "Creating the virtual machine (takes a while)"
New-AzVM `
  -ResourceGroupName $rg `
  -Location $loc `
  -VM $vmConfig `
> $null

ProgressHelper $currentActivity "Passing configuration variables to the .bashrc of the user $username"
ssh "$($username)@$($pip.IpAddress)" "echo '' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo '# RETRO-CLOUD: The environment variables below were set by the retro-cloud setup script.' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo 'export resourceGroupName=$rg' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo 'export storageAccountName=$storageAccountName' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo 'export storageAccountKey=$storageAccountKey' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo 'export fileShareName=$fileShareName' | sudo tee -a ~/.bashrc > /dev/null"
ssh "$($username)@$($pip.IpAddress)" "echo 'export smbPath=$smbPath' | sudo tee -a ~/.bashrc > /dev/null"

ProgressHelper "Done" " "

# Running without having to manually accept is: ssh -o `"StrictHostKeyChecking no`" $($username)@$($pip.IpAddress)
"VM is accessible with: ssh $($username)@$($pip.IpAddress)"
"Continue setup in the VM. See the Readme."
