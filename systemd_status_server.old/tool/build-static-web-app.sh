#!/bin/bash
set -eo pipefail

rm -rf web/app
pushd ../systemd_status_flutter
flutter build web --release \
  --output ../systemd_status_server/web/app \
  --no-web-resources-cdn --csp --source-maps --dump-info \
  --base-href '/app/'
popd
