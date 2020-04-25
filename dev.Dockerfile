FROM seriema/retro-cloud:develop

# Install PowerShell
# RUN wget -O - https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/dev/install-ps-ubuntu.sh | bash
COPY raspberry-pi/dev/install-ps-ubuntu.sh .
RUN bash install-ps-ubuntu.sh \
    && rm install-ps-ubuntu.sh

# Install Azure PowerShell module
# RUN wget https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/install-az-module.ps1 \
    # && pwsh -executionpolicy bypass -File "install-az-module.ps1"
COPY raspberry-pi/install-az-module.ps1 .
RUN pwsh -executionpolicy bypass -File "install-az-module.ps1" \
    && rm install-az-module.ps1

# docker build -t retro-cloud:rpi-dev --file dev.Dockerfile .
# docker run --privileged -it --rm --volume az:/home/pi/.Azure retro-cloud:rpi-dev /bin/bash
