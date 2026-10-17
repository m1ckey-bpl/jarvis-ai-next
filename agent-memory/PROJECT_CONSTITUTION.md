# PROJECT CONSTITUTION — jarvis-ai-next

> This file is the single source of truth for all permanent requirements.
> It overrides any other document, session memory, or style preference.
> Never modify silently. Changes require a DECISIONS.md entry.

---

## Identity

- **Project name:** jarvis-ai-next
- **Repository:** https://github.com/m1ckey-bpl/jarvis-ai-next
- **GitHub account:** m1ckey-bpl
- **Bundle ID:** ai.jarvis.next
- **Purpose:** Premium native iOS AI personal assistant — NOT a web app, NOT a chatbot, NOT a repair of any previous project

---

## Absolute Rules

### R1 — New project only
This is jarvis-ai-next — a completely independent project. Never read, reference, copy, or modify any other repository (including jarvis-ai-ios). Every design decision starts fresh.

### R2 — Native SwiftUI only
The main application interface must be native Swift/SwiftUI. No WebView as primary UI. No Electron. No React Native. No Capacitor. Minimum iOS 17.0.

### R3 — Real implementations only
Never create placeholder stubs, fake buttons, hardcoded responses, or simulated integrations. Every interactive element must have a real, implemented action. Never claim a feature works without evidence.

### R4 — Zero-cost budget
No paid services. No paid APIs. No paid cloud infrastructure. No paid runners. No subscriptions activated. Verify free-tier eligibility before choosing any service.

### R5 — No secrets in the repository
Never commit API keys, OAuth credentials, tokens, certificates, or provisioning profiles. Use .env files (gitignored) and iOS Keychain for runtime credentials.

### R6 — Unsigned IPA is mandatory
The CI pipeline must produce a real, structurally valid unsigned IPA. No signing certificates required. User handles signing separately with AltStore/Sideloadly.

### R7 — Engineering memory protocol
At the START of every session: read all 6 agent-memory files + check GitHub Actions status.
At the END of every session: update all 6 agent-memory files + commit + push.
Never silently discard a requirement. Never mark unfinished features complete.

### R8 — Never fabricate
Never fabricate test results, build artifacts, download links, API responses, or successful actions. Report actual results. If something failed, say so and explain why.

### R9 — Visual direction
- Deep graphite/black backgrounds (#0A0A0F range)
- Cyan accent (#00D9FF)
- Liquid Glass materials (translucent surfaces, subtle borders)
- Human-like avatar with speech-driven lip sync
- NO excessive neon, NO anime characters, NO copyrighted Marvel/Iron Man art, NO generic gradients

### R10 — Voice is core
Real-time voice is a primary feature. Use AVFoundation + SFSpeechRecognizer (input) + AVSpeechSynthesizer (output). The avatar's mouth must move in sync with actual spoken audio. Voice input/output must be tested on a physical device.

---

## Architecture Boundaries

| Layer | Technology | Notes |
|---|---|---|
| iOS App | SwiftUI, Swift 5.9+ | No UIKit-only patterns without SwiftUI wrapper |
| Engine | Swift Package (JarvisCore) | Pure Swift, no UIKit, testable |
| Backend | Python FastAPI | Optional; app works without it |
| AI | Gemini Flash (primary), Groq (fallback) | Free tiers |
| Voice In | SFSpeechRecognizer | On-device, free |
| Voice Out | AVSpeechSynthesizer | On-device, free |
| Memory | JSON file store | app-support directory |
| Secrets | iOS Keychain + server env | Never in source |
| CI | GitHub Actions macos-14 | Free public repo |

---

## Environment Facts

- **Dev OS:** Windows (PowerShell) — no local Xcode
- **Git binary:** `C:\Users\HP\AppData\Local\hermes\tools\git-2.53.0+3-win32-x64\bin\git.exe`
- **Python:** Available (3.13+)
- **Node.js:** Available (v22+)
- **iOS builds:** Via GitHub Actions macos-14 runner only
- **PAT for CI:** User supplies; never store in repo

---

## Session Protocol

### Session start (mandatory)
1. Read agent-memory/PROJECT_CONSTITUTION.md
2. Read agent-memory/CURRENT_STATE.md
3. Read agent-memory/DECISIONS.md
4. Read agent-memory/TASK_BACKLOG.md
5. Read agent-memory/KNOWN_ISSUES.md
6. Read agent-memory/SESSION_HANDOFF.md
7. Check https://github.com/m1ckey-bpl/jarvis-ai-next/actions — last CI status
8. Reconcile docs with actual files on disk
9. Pick next task from backlog

### Session end (mandatory)
1. Update CURRENT_STATE.md with verified progress
2. Update TASK_BACKLOG.md with completed/new tasks
3. Add new DECISIONS.md entries
4. Update KNOWN_ISSUES.md
5. Write SESSION_HANDOFF.md with exact next action
6. Commit and push all changes
