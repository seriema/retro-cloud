#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo
echo '###############################################################################'
echo '##########  Raspberry Pi  #####################################################'

echo
echo 'PRINT: RaspberryPi ~/.retro-cloud.env  ########################################'
cat "$HOME/.retro-cloud.env"

echo
echo 'PRINT: RaspberryPi ~/.bashrc  #################################################'
cat "$HOME/.bashrc"

echo
echo 'PRINT: RaspberryPi ~/ directory listing  ######################################'
bash -i retro-cloud-setup/dev/list-home.sh

echo
echo '###############################################################################'
echo '##########  File Share  #######################################################'

echo
echo 'PRINT: Azure File Share directory listing'
pwsh -executionpolicy bypass -File "./retro-cloud-setup/dev/list-az-share.ps1"

echo
echo '###############################################################################'
echo '##########  VM  ###############################################################'

echo
echo 'PRINT: VM ~/.retro-cloud.env  #################################################'
# shellcheck disable=SC2016
./ssh-vm.sh 'cat "$HOME/.retro-cloud.env"'

echo
echo 'PRINT: VM ~/.bashrc  ##########################################################'
# shellcheck disable=SC2016
./ssh-vm.sh 'cat "$HOME/.bashrc"'

echo
echo 'PRINT: VM ~/ directory listing  ###############################################'
./ssh-vm.sh 'bash -i retro-cloud-setup/dev/list-home.sh'

echo
echo 'PRINT: VM Skyscraper config  ##################################################'
./ssh-vm.sh 'cat ~/.skyscraper/config.ini'

#
# End

echo
echo '###############################################################################'
echo 'PRINT: Done.'
echo
