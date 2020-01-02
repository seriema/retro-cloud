mntPath="/mnt/$storageAccountName/$fileShareName"
smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
emulationstation="$HOME/.emulationstation"

sudo rm -r -f "$mntPath/output"
rm -r -f "$emulationstation"

sudo umount $mntPath 2> /dev/null

sudo rm -f $smbCredentialFile

sudo rm -r -f $mntPath

sudo sed -i.bak "/RETRO-CLOUD/d" /etc/fstab
sudo sed -i.bak "/$storageAccountName/d" /etc/fstab

echo 'Done!'
