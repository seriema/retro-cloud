Running ROMs from the cloud
---

An expensive and over-egineered approach to storing ROMs and their metadata which sets out to answer the question:
> Why buy a cheap USB stick when you can use multiple expensive services in the Cloud?

## Architecture

![architecture-diagram](diagrams/architecture.svg)

### File structure

![filestructure-diagram](diagrams/filestructure.svg)

## Setup

1. Create `scraper_vm` as Azure VM.
1. Create a user on `scraper_vm` called `pi`, this will allow paths from scraping to match what RetroPie expects.
1. Install [Skyscraper](https://github.com/muldjord/skyscraper) on `pi@scraper_vm`
1. Configure `Skyscraper`
    1. Transfer the [.skyscraper](.skyscraper/) folder to `pi@scraper_vm/~/.skyscraper`
1. Create `scraper_storage` as Azure File Share.
1. Mount `scraper_storage` as `pi@scraper_vm/` so `pi`-user has **read and write access** rights.
1. Create `roms_storage`
1. Mount `roms_storage` as `pi@scraper_vm/.../roms` so `pi`-user with **only read access**
1. Create a SSH key in `raspberry_pi` and send the public key to `scraper_vm`, so `pi@raspberry_pi` can log into `pi@scraper_vm`.
1. Move `raspberry_pi:home/pi/RetroPie/roms` to `raspberry_pi:home/pi/RetroPie/roms.bak`.
1. Move `raspberry_pi:home/pi/RetroPie/gamelists` to `raspberry_pi:home/pi/RetroPie/gamelists.bak`.
1. Mount `pi@scraper_vm` on `pi@raspberry_pi:home/pi/mount/scraper_vm/` with **only read access**
1. Symlink `raspberry_pi:home/pi/mount/scraper_vm/roms` as `raspberry_pi:home/pi/RetroPie/roms`
1. Symlink `raspberry_pi:home/pi/mount/scraper_vm/gamelists` as `raspberry_pi:home/pi/RetroPie/gamelists`
1. Reboot `raspberry_pi`

### Using scripts

1. On the Raspberry Pi:
    ```
    wget -O - https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/setup.sh | bash
    ```
