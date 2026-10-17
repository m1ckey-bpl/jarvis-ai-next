#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${1:-$ROOT_DIR/build}"
DIST_DIR="$ROOT_DIR/dist"
VERSION="${MARKETING_VERSION:-1.0.0}"
IPA_NAME="JarvisApp-${VERSION}-unsigned"

mkdir -p "$DIST_DIR"

echo "==> Searching for JarvisApp.app in: $BUILD_DIR"
APP_PATH=$(find "$BUILD_DIR" -type d -name "JarvisApp.app" -print -quit 2>/dev/null || true)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "ERROR: JarvisApp.app not found in $BUILD_DIR" >&2
    exit 1
fi

echo "==> Found bundle at: $APP_PATH"
PAYLOAD_DIR=$(mktemp -d)
trap 'rm -rf "$PAYLOAD_DIR"' EXIT

mkdir -p "$PAYLOAD_DIR/Payload"
cp -R "$APP_PATH" "$PAYLOAD_DIR/Payload/"

IPA_OUT="$DIST_DIR/${IPA_NAME}.ipa"
rm -f "$IPA_OUT"

echo "==> Packaging unsigned IPA..."
(cd "$PAYLOAD_DIR" && zip -qr "$IPA_OUT" Payload/)

echo "==> Computing checksum..."
if command -v shasum >/dev/null 2>&1; then
    SHA256=$(shasum -a 256 "$IPA_OUT" | awk '{print $1}')
elif command -v sha256sum >/dev/null 2>&1; then
    SHA256=$(sha256sum "$IPA_OUT" | awk '{print $1}')
else
    SHA256="unavailable"
fi

echo "$SHA256  ${IPA_NAME}.ipa" > "${IPA_OUT}.sha256"

echo "=================================================="
echo "✅ SUCCESS: Packaged unsigned IPA"
echo "   File:   $IPA_OUT"
echo "   SHA256: $SHA256"
echo "=================================================="
