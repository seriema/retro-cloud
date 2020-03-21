#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'Verify access rights on user home and RetroPie'
[ $(stat -c %a /home/pi) -eq 755 ]
[ $(stat -c %a /home/pi/RetroPie) -eq 755 ]
[ $(stat -c %a /home/pi/RetroPie-Setup) -eq 755 ]

echo 'Verify group memberships'
[ "$(groups | grep pi)" ]
[ "$(groups | grep sudo)" ]

echo 'Verify username'
[ "$(whoami)" = "pi" ]
