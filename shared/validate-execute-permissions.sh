#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# Turned into a function so testing can be silent but on finding files the files can be listed.
findFilesWithoutExecutionPermission () {
    find . -type f -name '*.sh' -not -executable;
}

if [ "$(findFilesWithoutExecutionPermission | wc -l)" -ne 0 ]; then
    echo 'These files are lacking execute (+x) permission:'
    findFilesWithoutExecutionPermission
    exit 1;
fi
