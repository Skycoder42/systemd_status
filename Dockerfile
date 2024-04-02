FROM dart:latest AS build_rpc
WORKDIR /src/systemd_status_rpc

COPY systemd_status_rpc/pubspec.* ./
RUN dart pub get

COPY systemd_status_rpc .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs

FROM dart:latest AS build_server
WORKDIR /src/systemd_status_server

COPY --from=build_rpc /src/systemd_status_rpc/pubspec.* /src/systemd_status_rpc/
COPY systemd_status_server/pubspec.* ./
RUN dart pub get

COPY --from=build_rpc /src/systemd_status_rpc /src/systemd_status_rpc
COPY systemd_status_server .
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs

RUN dart compile exe bin/main.dart -o bin/systemd-status-server

FROM scratch

COPY --from=build_server /runtime/ /
COPY --from=build_server /src/systemd_status_server/bin/systemd-status-server /app/bin/systemd-status-server
COPY --from=build_server /src/systemd_status_server/config/ /app/config/
COPY --from=build_server /src/systemd_status_server/web/ /app/web/
WORKDIR /app

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

ENTRYPOINT [ "/app/bin/systemd-status-server" ]
CMD [ "--mode", "production", "--role", "monolith" ]
