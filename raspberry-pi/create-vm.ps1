###################################
# Create VM
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell

# Check for existing SSH public key file
# if exists: /home/pi/.ssh/id_rsa.pub
# else: ssh-keygen -t rsa -b 2048

# Create a resource group
New-AzResourceGroup -Name "retro-cloud-test" -Location "EastUS"
