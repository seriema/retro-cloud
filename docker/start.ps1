param (
    [string]$branch = "$(git rev-parse --abbrev-ref HEAD)"
)

# Abort on error
$ErrorActionPreference = "Stop"

docker run `
    --cap-add SYS_ADMIN `
    --device /dev/fuse `
    --env-file .env `
    --interactive `
    --rm `
    --tty `
    --volume powershell-install:/opt/microsoft/powershell `
    --volume "$($PWD.Path):/home/pi/retro-cloud-source" `
    --workdir /home/pi/retro-cloud-source `
    "rc:$branch"
