#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "==> Validating project structure in $ROOT_DIR..."

REQUIRED_FILES=(
    "README.md"
    ".gitignore"
    ".env.example"
    "agent-memory/PROJECT_CONSTITUTION.md"
    "agent-memory/CURRENT_STATE.md"
    "agent-memory/DECISIONS.md"
    "agent-memory/TASK_BACKLOG.md"
    "agent-memory/KNOWN_ISSUES.md"
    "agent-memory/SESSION_HANDOFF.md"
    "ios/Package.swift"
    "ios/JarvisApp.xcodeproj/project.pbxproj"
    "ios/JarvisApp/Info.plist"
    "ios/JarvisApp/App/JarvisApp.swift"
    "ios/JarvisApp/App/AppEnvironment.swift"
    "ios/JarvisApp/App/RootView.swift"
    "ios/JarvisApp/App/MainShell.swift"
    "ios/JarvisApp/Screens/AssistantHomeView.swift"
    "ios/JarvisCore/Sources/JarvisCore/Providers/AIProvider.swift"
    "ios/JarvisCore/Sources/JarvisCore/Providers/GeminiProvider.swift"
    "ios/JarvisCore/Sources/JarvisCore/Providers/GroqProvider.swift"
    "ios/JarvisCore/Sources/JarvisCore/Voice/SpeechEngine.swift"
    "ios/JarvisCore/Sources/JarvisCore/Voice/VisemeEngine.swift"
    "ios/JarvisCore/Sources/JarvisCore/Memory/MemoryStore.swift"
    "ios/JarvisCore/Sources/JarvisCore/Agent/AgentOrchestrator.swift"
    ".github/workflows/ios.yml"
)

ERRORS=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$ROOT_DIR/$file" ]; then
        echo "❌ MISSING: $file"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ OK: $file"
    fi
done

# Check for accidental committed secrets
echo "==> Checking for uncommitted secrets..."
if grep -rn "ghp_" "$ROOT_DIR" --exclude-dir=".git" --exclude-dir="scratch" 2>/dev/null; then
    echo "❌ ERROR: Found GitHub PAT in project files!"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ No hardcoded GitHub tokens found"
fi

if [ $ERRORS -eq 0 ]; then
    echo "=================================================="
    echo "✅ ALL VALIDATION CHECKS PASSED (${#REQUIRED_FILES[@]} files verified)"
    echo "=================================================="
    exit 0
else
    echo "=================================================="
    echo "❌ VALIDATION FAILED WITH $ERRORS ERRORS"
    echo "=================================================="
    exit 1
fi
