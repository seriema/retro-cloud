#!/bin/bash

# Do not stop on error, because these prints are to help debug when any setup or test steps fail. The error is piped to an error handler instead of aborting.
# Example: Printing .retro-cloud.env on the VM might fail because it's missing, but it's still valuable to see all the other prints.
# Abort on error, and error if variable is unset
set -eu

exitCode=0
print_fail() {
    exitCode=$?
    echo -en '\e[40;31mPRINT: Failed! The script will continue as there might be a print with a clue.  ##############################################################################'
    echo
}

echo
echo '##############################################################################################################################################################'
echo '##########  Raspberry Pi  ####################################################################################################################################'

echo
echo 'PRINT: RaspberryPi ~/.retro-cloud.env  #######################################################################################################################'
cat "$HOME/.retro-cloud.env" || print_fail

echo
echo 'PRINT: RaspberryPi ~/.bashrc  ################################################################################################################################'
cat "$HOME/.bashrc" || print_fail

echo
echo 'PRINT: RaspberryPi ~/ directory listing  #####################################################################################################################'
bash -i retro-cloud-setup/dev/list-home.sh || print_fail

echo
echo '##############################################################################################################################################################'
echo '##########  File Share  ######################################################################################################################################'

echo
echo 'PRINT: Azure File Share directory listing'
pwsh -executionpolicy bypass -File "./retro-cloud-setup/dev/list-az-share.ps1" || print_fail

echo
echo '##############################################################################################################################################################'
echo '##########  VM  ##############################################################################################################################################'

echo
echo 'PRINT: VM ~/.retro-cloud.env  ################################################################################################################################'
# shellcheck disable=SC2016
./ssh-vm.sh 'cat "$HOME/.retro-cloud.env"' || print_fail

echo
echo 'PRINT: VM ~/.bashrc  #########################################################################################################################################'
# shellcheck disable=SC2016
./ssh-vm.sh 'cat "$HOME/.bashrc"' || print_fail

echo
echo 'PRINT: VM ~/ directory listing  ##############################################################################################################################'
./ssh-vm.sh 'bash -i retro-cloud-setup/dev/list-home.sh' || print_fail

echo
echo 'PRINT: VM Skyscraper config  #################################################################################################################################'
./ssh-vm.sh 'cat ~/.skyscraper/config.ini' || print_fail

#
# End

echo
echo '##############################################################################################################################################################'
echo 'PRINT: Done.'
echo

exit $exitCode
