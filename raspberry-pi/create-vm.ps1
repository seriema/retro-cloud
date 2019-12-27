# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell

# Don't create new resources if there's an error
$ErrorActionPreference = "Stop"

# Check for existing SSH public key, otherwise create one.
if (![System.IO.File]::Exists("/home/pi/.ssh/id_rsa.pub")) {
  ssh-keygen -t rsa -b 2048
}

# Shared variables
$prefix = Get-Date -Format "M-d_HH-mm-ss_"
$rg = "$($prefix)retro-cloud-test"
$loc = "EastUS"

# Create a resource group
New-AzResourceGroup `
  -Name $rg `
  -Location $loc `
> $null

# ###################################
# Create VMCreate virtual network resources

## Create a virtual network, subnet, and a public IP address.

# Create a subnet configuration
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "subnet" `
  -AddressPrefix 192.168.1.0/24

# Create a virtual network
$vnet = New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "vnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

# Create a public IP address and specify a DNS name
$pip = New-AzPublicIpAddress `
  -ResourceGroupName $rg `
  -Location $loc `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -Name "publicdns$(Get-Random)"

## Create an Azure Network Security Group and traffic rule.

# Create an inbound network security group rule for port 22
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

# Create an inbound network security group rule for port 80
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

# Create a network security group
$nsg = New-AzNetworkSecurityGroup `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name "networkSecurityGroup" `
  -SecurityRules $nsgRuleSSH,$nsgRuleWeb

## Create a virtual network interface card (NIC)
# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzNetworkInterface `
  -Name "nic" `
  -ResourceGroupName $rg  `
  -Location $loc `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id

###################################
# Create the storage account for scraping cache and boot diagnostics
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
$storageAccountName = ("$($prefix)storage" -replace '[^A-Za-z0-9]+', '').ToLower()

# Create the storage account.
$storageAccount = New-AzStorageAccount `
  -ResourceGroupName $rg `
  -Location $loc `
  -Name $storageAccountName `
  -SkuName "Standard_LRS"

###################################
# Create the virtual machine

# Define a credential object
$username = "pi"
$securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

# Create a virtual machine configuration
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

# Configure the SSH key
$sshPublicKey = cat ~/.ssh/id_rsa.pub
Add-AzVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/$username/.ssh/authorized_keys" `
> $null

# Create the VM
New-AzVM `
  -ResourceGroupName $rg `
  -Location $loc `
  -VM $vmConfig `
> $null

# This can't run on Linux VM's so I'll have to run the script manually from the VM, or learn more about what's possible with cloud-init.
# $script = "https://raw.githubusercontent.com/seriema/retro-cloud/develop/vm/install-skyscraper.sh"
# Set-AzVMCustomScriptExtension `
#   -ResourceGroupName $rg `
#   -Location $loc `
#   -FileUri $script `
#   -Run install-skyscraper.sh `
#   -Name "Install-Skyskraper" `
#   -VMName $vmName

"Storage is accessible at: $($storageAccount.Context.FileEndPoint)"
"VM is accessible with: ssh -o `"StrictHostKeyChecking no`" $($username)@$($pip.IpAddress)"
