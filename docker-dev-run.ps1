# Abort on error
$ErrorActionPreference = "Stop"

$branch = "$(git rev-parse --abbrev-ref HEAD)"

docker run `
    --env AZURE_TENANT_ID="$Env:RC_DEV_AZURE_TENANT_ID" `
    --env AZURE_SERVICE_PRINCIPAL_USER="$Env:RC_DEV_AZURE_SERVICE_PRINCIPAL_USER" `
    --env AZURE_SERVICE_PRINCIPAL_SECRET="$Env:RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET" `
    --interactive `
    --privileged `
    --rm `
    --tty `
    --volume powershell-install:/opt/microsoft/powershell `
    --volume "$($PWD.Path):/home/pi/retro-cloud-source" `
    --workdir /home/pi/retro-cloud-source `
    "rc:$branch"
