FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

RUN apt-get update && apt-get install -y openssl
RUN apt-get install -y gawk

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish

FROM base AS final
WORKDIR /app
COPY --from=build /src/dev-proxy-plugins/bin/Release/net8.0/publish ./plugins/
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/presets ./presets/
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/*.dll ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/devproxy ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/devproxy.runtimeconfig.json ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/devproxy-errors.json ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/msgraph-openapi-v1.db ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/toggle-proxy.sh ./
COPY --from=build /src/dev-proxy/bin/Release/net8.0/publish/trust-cert.sh ./
COPY dev-proxy/devproxyrc-docker.json ./devproxyrc.json
COPY dev-proxy/entrypoint.sh ./
COPY dev-proxy/recordings.sh ./

RUN chmod +x /app/entrypoint.sh \
    && chmod +x /app/recordings.sh \
    && mkdir /mocks 

EXPOSE 8000
CMD ["/app/entrypoint.sh"]