#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

bash -i test-copy-rom.sh

bash -i ../local/run-skyscraper.sh

bash -i test-gamelist.sh
