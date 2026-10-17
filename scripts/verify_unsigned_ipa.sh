#!/usr/bin/env bash
set -euo pipefail

IPA_PATH="${1:-}"

if [ -z "$IPA_PATH" ] || [ ! -f "$IPA_PATH" ]; then
    echo "Usage: $0 <path-to-ipa>" >&2
    exit 1
fi

echo "==> Verifying unsigned IPA: $IPA_PATH"

# Check zip structure
if ! unzip -tq "$IPA_PATH" >/dev/null 2>&1; then
    echo "❌ ERROR: File is not a valid zip archive." >&2
    exit 1
fi
echo "✅ Valid zip archive"

# Check for Payload/JarvisApp.app
CONTENTS=$(unzip -l "$IPA_PATH")

if ! echo "$CONTENTS" | grep -q "Payload/JarvisApp.app/"; then
    echo "❌ ERROR: Missing Payload/JarvisApp.app directory inside archive." >&2
    exit 1
fi
echo "✅ Contains Payload/JarvisApp.app/"

# Check Info.plist
if ! echo "$CONTENTS" | grep -q "Payload/JarvisApp.app/Info.plist"; then
    echo "❌ ERROR: Missing Info.plist inside bundle." >&2
    exit 1
fi
echo "✅ Contains Info.plist"

# Verify unsigned (no embedded mobileprovision)
if echo "$CONTENTS" | grep -q "embedded.mobileprovision"; then
    echo "⚠️ Warning: Archive contains embedded.mobileprovision (expected unsigned)."
else
    echo "✅ Clean unsigned bundle (no embedded.mobileprovision)"
fi

echo "=================================================="
echo "✅ IPA VERIFICATION PASSED: Structurally sound"
echo "=================================================="
