# Abort on error
$ErrorActionPreference = "Stop"

$branch="$(git rev-parse --abbrev-ref HEAD)"

docker run `
    --rm `
    --volume "$($PWD.Path)/docker/compose:/home/pi/retro-cloud-test/docker/compose" `
    --workdir "/home/pi/retro-cloud-test" `
    --cap-add SYS_ADMIN `
    --device /dev/fuse `
    "rc:$branch" `
    bash ./docker/compose/run_tests.sh
