#!/bin/sh
set -e

rm -rf build/web
flutter build web \
  --source-maps \
  --dump-info \
  --no-web-resources-cdn \
  --base-href=/app/ \
  --dart-define=FIREBASE_API_KEY='%{FIREBASE_API_KEY_PLACEHOLDER}' \
  --dart-define=SENTRY_DSN='%{SENTRY_DSN_PLACEHOLDER}'
