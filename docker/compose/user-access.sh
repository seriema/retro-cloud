#!/bin/bash

# Abort on error, error if variable is unset, and enable debug output
set -eux

echo 'Verify access rights on user home and RetroPie'
[[ $(stat -c %a /home/pi) -eq 755 ]]
[[ $(stat -c %a /home/pi/RetroPie) -eq 755 ]]
[[ $(stat -c %a /home/pi/RetroPie-Setup) -eq 755 ]]
# [[ $(stat -c %a /dev/fuse) -eq 666 ]]

echo 'Verify group memberships'
[[ $(groups | grep pi) ]]
[[ $(groups | grep sudo) ]]

echo 'Verify username'
[[ $(whoami) = "pi" ]]
