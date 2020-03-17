Running ROMs from the cloud
---

An expensive and over-engineered approach to storing ROMs and their metadata which sets out to answer the question:
> Why buy a cheap USB stick when you can use multiple expensive services in the Cloud?

## Architecture

![architecture-diagram](diagrams/architecture.svg)

### File structure

![filestructure-diagram](diagrams/filestructure.svg)

## Setup

1. Install Retro-Cloud on the Raspberry Pi (creates the VM for step 2):

    ```bash
    $ wget -O - https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/download-and-run.sh | bash
    ```

    > **NOTE!** You will be prompted to log into your Azure account. The script pauses with the message:
    >
    > `WARNING: To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code ABCD12345 to authenticate.`

1. Install Retro-Cloud on the VM. Alternatives:
    * On the Raspberry Pi:

        ```bash
        $ bash -i setup-vm.sh
        ```

    * On the VM. Log into the VM from the RPi with `$ bash -i ssh-vm.sh`, or any other way you want, and then run:

        ```bash
        $ wget -O - https://raw.githubusercontent.com/seriema/retro-cloud/develop/virtual-machine/setup.sh | bash -i
        ```

1. Copy ROMs to Azure File Share. Alternatives:
    * If you already had ROMs on the Raspberry Pi: They're now in `roms.bak` and can be copied over:

        ```bash
        $ cp -R RetroPie/roms.bak/. RetroPie/roms/
        ```

    * If you have ROMs on a desktop: Use [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/) and copy them to `Storage Accounts/[numbers]storage/Files Shares/retro-cloud/RetroPie/roms`
1. Scrape for metadata. Alternatives:
    > Note: This will take a _long_ time. A test run of 6 platforms with 13k files took 10 hours. EmulationStation must not be running during this time.
    * On the Raspberry Pi: `$ bash -i run-scraper.sh`
    * On the VM: `$ ./run-skyscraper.sh`

## Development

### Prerequisites

* PowerShell Core 6+
* Bash 4.4.12+

### Workflow

* Development
    * `docker-dev-build.sh` to build a Docker image meant for running locally. The tag is `rc:(branch name)`.
    * `docker-dev-run.sh` to run a throwaway Docker container with multiple volumes attached to store the pre-requisites from the setup scripts (i.e. PowerShell).
* Testing scripts inside a container
    * To work with the repo: `git clone git@github.com:seriema/retro-cloud.git && cd retro-cloud && git checkout develop`
    * To test as a user:
        * Follow the "Setup" section above.
    * To test a specific branch as a user:
        * `branch=[the branch you want to test]`, e.g. `branch=upgrade-powershell`
        * `wget -nv "https://raw.githubusercontent.com/seriema/retro-cloud/${branch}/raspberry-pi/download-and-run.sh"`
        * `bash download-and-run.sh "$branch"`
        * `rm download-and-run.sh`
* Docker Hub
    * `docker-build.sh` to build a production Docker image.
    * `docker-push.sh` to push the built production Docker image to Docker Hub.
    * `docker-run.sh` pulls a production image from Docker Hub and runs it.

### Notes on Windows

Preferably use Bash (`docker-run.sh` doesn't work in Git Bash) and the scripts above. As a fallback use PowerShell or any terminal that runs Docker and use these commands:

* Development
    * `docker run --privileged --rm -it -v azure-context:/.Azure -v home:/home/pi -v powershell:/home/pi/powershell -v pwsh-bin:/usr/bin rc:dev`
    * `git clone https://github.com/seriema/retro-cloud.git && cd retro-cloud && git checkout develop`
* Docker Hub
    * build: `docker build -t seriema/retro-cloud:amd64 .`
    * push: `docker push seriema/retro-cloud:amd64`
    * run: `docker pull seriema/retro-cloud:amd64 && docker run --privileged --rm -it seriema/retro-cloud:amd64`
