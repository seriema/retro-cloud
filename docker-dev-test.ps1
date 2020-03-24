# Abort on error
$ErrorActionPreference = "Stop"

$branch="$(git rev-parse --abbrev-ref HEAD)"

docker run `
    --rm `
    --volume "$($PWD.Path):/home/pi/retro-cloud-source" `
    --workdir "/home/pi/retro-cloud-source" `
    --cap-add SYS_ADMIN `
    --device /dev/fuse `
    "rc:$branch" `
    bash ./docker/compose/run_tests.sh
