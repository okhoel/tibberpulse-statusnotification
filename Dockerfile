# Pull base image
FROM mcr.microsoft.com/powershell:7.3-alpine-3.14

# Labels
LABEL MAINTAINER="Ole Kristian Hoel <okhoel@gmail.com>"

#Environment variables
ENV POWERSHELL_TELEMETRY_OPTOUT=1

#Install Tibber module
RUN pwsh -command "Install-Module -Name PStibber -Scope CurrentUser -Force"

ADD CheckPulseStatus.ps1 /

CMD [ "pwsh", "./CheckPulseStatus.ps1" ]
#CMD [ "pwsh" ]