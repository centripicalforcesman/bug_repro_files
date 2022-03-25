FROM mcr.microsoft.com/dotnet/sdk:6.0 AS Build
WORKDIR /app
COPY *.sln ./
COPY HeadlessChrome/*.csproj ./HeadlessChrome/
COPY HeadlessChrome.API.Core/*.csproj ./HeadlessChrome.API.Core/
COPY HeadlessChrome.Test/*.csproj ./HeadlessChrome.Test/
RUN dotnet restore
COPY ./ .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
ARG CHROME_VERSION="86.0.4240.75-1"

RUN apt-get update && apt-get -f install && apt-get -y install wget gnupg2 apt-utils
#RUN wget http://ftp.us.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-4_amd64.deb
#RUN wget http://ftp.us.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb
#RUN apt-get update && apt-get -f --assume-yes install ./libindicator3-7_0.5.0-4_amd64.deb ./libappindicator3-1_0.4.92-7_amd64.deb
RUN wget --no-verbose -O /tmp/chrome.deb http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb \
&& apt-get update \
&& apt-get install -y /tmp/chrome.deb --no-install-recommends --allow-downgrades fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
&& rm /tmp/chrome.deb
#RUN apt-get update \
#    && apt-get install -y chromium
COPY --from=Build   /app/out  .

ENV LOGGING__LOGLEVEL__DEFAULT="Debug"
ENV LOGGING__LOGLEVEL__MICROSOFT="Warning"
ENV Application__Settings__Default_Timeout="30"

ENV NUMBER__BROWSERS="10"

ENTRYPOINT [ "dotnet", "HeadlessChrome.dll", "--urls", "http://0.0.0.0" ]
