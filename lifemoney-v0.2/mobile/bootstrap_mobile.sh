#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed. Install Flutter 3.47+ and rerun this script."
  exit 1
fi
TMP="$(mktemp -d)"
cp pubspec.yaml "$TMP/pubspec.yaml"
cp -r lib "$TMP/lib"
flutter create --project-name lifemoney_app --platforms=android,ios .
cp "$TMP/pubspec.yaml" pubspec.yaml
rm -rf lib
cp -r "$TMP/lib" lib
flutter pub get
printf '\nMobile project ready. Start the API, then run: flutter run\n'
