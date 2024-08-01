#!/bin/bash
set -eo pipefail

# cider bump "$@"
# cider release

version=$(yq '.version' pubspec.yaml)

server_pubspec=../server/pubspec.yaml
edit="with(.aur.extraSources[0];
  .name = \"Systemd.Status.Web-$version.tar.xz\" |
  .url = \"https://github.com/Skycoder42/systemd_status/releases/download/client%2Fv$version/Systemd.Status.Web.tar.xz\"
)"
yq "$edit" "$server_pubspec" \
  | diff -B "$server_pubspec" - \
  | patch "$server_pubspec" -
