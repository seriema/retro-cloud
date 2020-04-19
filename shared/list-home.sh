#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

sudo find "$HOME" | sed -e "s/[^-][^\/]*\// |/g" -e "s/|\([^ ]\)/|-\1/"
