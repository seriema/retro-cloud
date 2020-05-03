param (
    [string]$branch = "$(git rev-parse --abbrev-ref HEAD)"
)

# Abort on error
$ErrorActionPreference = "Stop"

"Create the container"
$containerInstance = docker container create `
    --cap-add SYS_ADMIN `
    --device /dev/fuse `
    --env-file .env `
    --interactive `
    --rm `
    --tty `
    --volume powershell-install:/opt/microsoft/powershell `
    --volume powershell-modules-cache:/home/pi/.cache/powershell `
    --volume powershell-modules-config:/home/pi/.config/NuGet `
    --volume powershell-azure-context:/home/pi/.Azure `
    --volume "$($PWD.Path):/home/pi/retro-cloud-source" `
    --workdir /home/pi/retro-cloud-source `
    "rc:$branch"

"Copy SSH"
# We want writable .ssh/known_hosts but not risk that our own .ssh/ directory gets broken
docker cp "$HOME/.ssh" "${containerInstance}:/home/pi/.ssh"

"Start the prepared container"
docker container start "$containerInstance"

"Symlink the PowerShell binary as 'pwsh', like install-ps.sh does"
docker exec -d "$containerInstance" sudo ln --symbolic "/opt/microsoft/powershell/7/pwsh" "/usr/bin/pwsh"

"Attach to the container"
docker container attach "$containerInstance"
