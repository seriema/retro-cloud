#!/bin/bash

# Abort on error, error if variable is unset, and enable debug output
set -eux

echo 'Verify access permissions of different directories'
# Added when the user was created as root so the user didn't have regular access to $HOME.
[[ $(stat -c %a /home/pi) -eq 755 ]]
# Added when RetroPie-Setup was running as another user than expected so the user didn't have access.
[[ $(stat -c %a /home/pi/RetroPie) -eq 755 ]]
# Added when 'git clone' required chmod but shouldn't have needed to.
[[ $(stat -c %a /home/pi/RetroPie-Setup) -eq 755 ]]
# Note: /dev/fuse test is only available at runtime so this test doesn't test the image. It would
# test the running container. It's only a problem when running the container on Windows/amd64 but
# it means that mounting won't work and running raspberry-pi/mount-vm-share.sh will fail.
# [[ $(stat -c %a /dev/fuse) -eq 666 ]]

echo 'Verify group memberships'
# Added when replacing 'useradd' with 'adduser' to verify that the user gets a group with the same name.
[[ $(groups | grep pi) ]]
# Added when replacing 'useradd' with 'adduser' to verify that the user is still given sudo rights.
[[ $(groups | grep sudo) ]]

echo 'Verify that the image default user is "pi"'
# Added when not setting "USER pi" as the last user in the Dockerfile.
[[ $(whoami) = "pi" ]]
