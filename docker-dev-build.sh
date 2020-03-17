#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"

docker build -t "rc:$branch" .
