#!/bin/bash
# Keep this minimal. Anything that touches RetroPie can break in upgrades.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# Speed up start time of EmulationStation by not scanning the mounted drives for ROMs
# https://retropie.org.uk/forum/post/220574
echo 'CONFIGURE: RetroPie'
settingsFile="$HOME/.emulationstation/es_settings.cfg";
originalSetting='<bool name="ParseGamelistOnly" value="false" />';
newSetting='<bool name="ParseGamelistOnly" value="true" />';

# If the file exists, replace the setting (if it exists)
if [[ -f "$settingsFile" ]]; then
    if grep -q "$originalSetting" "$settingsFile"; then
        sed -i -e "s+$originalSetting+$newSetting+g" "$settingsFile"
    else
        echo "$newSetting" >> "$settingsFile"
    fi
# Otherwise create the file and add the setting
else
    echo '<?xml version="1.0"?>' > "$settingsFile"
    echo "$newSetting" >> "$settingsFile"
fi

echo 'CONFIGURE: Done.'
