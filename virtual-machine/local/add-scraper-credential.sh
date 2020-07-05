#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

if [[ $# -ne 3 || -z $1 || -z $2 || -z $3 ]]; then
    echo
    echo "Usage: ./add-scraper-credential.sh MODULE USER PASSWORD"
    echo
    echo "Adds a scraper module section to Skyscraper config"
    echo
    echo "    MODULE      The scraping module. Such as 'screenscraper', 'openretro', etc."
    echo "    USER        Your username for that scraping module."
    echo "    PASSWORD    Your password for that scraping module."
    echo
    echo "More info: https://github.com/muldjord/skyscraper/blob/master/docs/CONFIGINI.md#usercredscredentials-or-key"
    echo
    echo "Example: ./add-scraper-credential.sh screenscraper seriema secretpassword"
    exit 2
fi

module=$1
user=$2
password=$3

echo '' | tee -a "$HOME/.skyscraper/config.ini"
echo "[$module]" | tee -a "$HOME/.skyscraper/config.ini"
echo "userCreds=\"${user}:${password}\"" | tee -a "$HOME/.skyscraper/config.ini"
