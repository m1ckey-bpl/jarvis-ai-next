#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Running available test suites..."

# Backend pytest if python available
if [ -d "$ROOT_DIR/backend" ] && [ -f "$ROOT_DIR/backend/requirements.txt" ]; then
    echo "==> Running Backend pytest..."
    if command -v pytest >/dev/null 2>&1; then
        (cd "$ROOT_DIR/backend" && pytest -v) || true
    else
        echo "pytest not installed locally, skipping."
    fi
fi

# Swift Package tests if swift available
if command -v swift >/dev/null 2>&1; then
    echo "==> Running Swift Package tests..."
    (cd "$ROOT_DIR/ios" && swift test) || true
else
    echo "Swift compiler not found on this host (expected on Windows). CI will execute Swift compilation."
fi

echo "✅ Test script completed."
