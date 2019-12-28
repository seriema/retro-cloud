#!/bin/bash

echo "SETUP: Download scripts to tmp/retro-cloud"
cd
mkdir -p tmp/retro-cloud
cd tmp/retro-cloud
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/create-vm.ps1
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/install-az-module.ps1
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/install-ps.sh
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/setup-az.ps1

echo "SETUP: Install PowerShell"
sh ./install-ps.sh

echo "SETUP: Run PowerShell scripts"
pwsh -executionpolicy bypass -File ".\setup-az.ps1"

echo "SETUP: Delete tmp/retro-cloud"
cd
rm -r tmp/retro-cloud

echo "SETUP: Done!"
