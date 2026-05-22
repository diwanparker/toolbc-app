#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$ROOT_DIR/pubspec.yaml" || ! -d "$ROOT_DIR/lib" ]]; then
  echo "Jalankan script ini dari root repo Flutter toolbc-app."
  exit 1
fi

cp -R "$PATCH_DIR/files/." "$ROOT_DIR/"

echo "Patch release hardening sudah disalin."
echo "Langkah berikutnya:"
echo "  1. Review diff: git diff"
echo "  2. Jalankan: flutter pub get && flutter analyze && flutter test"
echo "  3. Rotate API key yang pernah bocor sebelum commit/publish."
