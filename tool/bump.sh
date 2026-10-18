#!/bin/bash
set -eo pipefail

usage() {
  echo "Usage: $0 [patch|minor|major] [a|added|c|changed|d|deprecated|f|fixed|r|removed|s|security] [<message>...]" >&2
  echo "  Defaults: patch changed" >&2
  exit 1
}

level=${1:-patch}
category=${2:-changed}
message="${*:3}"

case "$level" in
  patch|minor|major) ;;
  *) usage ;;
esac

case "$category" in
  a|added) category=added ;;
  c|changed) category=changed ;;
  d|deprecated) category=deprecated ;;
  f|fixed) category=fixed ;;
  r|removed) category=removed ;;
  s|security) category=security ;;
  *) usage ;;
esac

cd "$(dirname "$0")/.."

for package in client server; do
  echo "=== Bumping $package ==="
  cider --project-root "$package" log "$category" "$message"
  cider --project-root "$package" bump "$level"
done

client_version=$(cider --project-root client version)
echo "=== Updating embedded web client reference to $client_version ==="
sed -i -E \
  -e "s|(Systemd\.Status\.Web-)[^/]+(\.tar\.xz)|\1$client_version\2|" \
  -e "s|(releases/download/client%2Fv)[^/]+(/Systemd\.Status\.Web\.tar\.xz)|\1$client_version\2|" \
  server/pubspec.yaml

for package in client server; do
  echo "=== Releasing $package ==="
  cider --project-root "$package" release > /dev/null
  echo "$package: $(cider --project-root "$package" version)"
done
