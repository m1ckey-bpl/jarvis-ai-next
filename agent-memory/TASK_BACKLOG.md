# TASK BACKLOG — jarvis-ai-next

**Legend:** `DONE` · `IMPL` · `WIP` · `TODO` · `BLOCKED`

---

## Milestones

| # | Milestone | Status | Evidence |
|---|---|---|---|
| 1 | Repository & Specification from Zero | DONE | Fresh git repo `jarvis-ai-next` (no code reuse) |
| 2 | iOS Native Compilation Checkpoint | DONE | Xcode 15.4 compiler passed on `macos-14` (Run #39053384396) |
| 3 | Liquid Glass Design System | DONE | SwiftUI translucent surfaces, 44pt touch targets |
| 4 | Avatar Digital Visage & Lip Sync | DONE | `JarvisFace` + `VisemeEngine` vowel phoneme math |
| 5 | AI Provider Abstraction | DONE | Gemini Flash + Groq REST and streaming clients |
| 6 | Real-time Voice Engine | DONE | `SFSpeechRecognizer` + `AVSpeechSynthesizer` |
| 7 | Persistent Runtime Memory | DONE | `MemoryStore` actor with keyword search |
| 8 | Agent Loop & Tool Registry | DONE | `AgentOrchestrator` + `ToolRegistry` |
| 9 | Reminders & Notifications | DONE | `ReminderManager` + `UNUserNotificationCenter` |
| 10 | Services & Integrations Framework | DONE | Gmail, GitHub, Calendar, Reminders UI + policies |
| 11 | Automated Testing & CI | DONE | GitHub Actions `ios.yml` build & packaging |
| 12 | Unsigned IPA Deliverable | DONE | `JarvisApp-1.0.0-unsigned.ipa` published on v1.0.0 Release |

---

## Next User Step (On-Device Verification)

1. Download `JarvisApp-1.0.0-unsigned.ipa` from the GitHub Release page or local staging.
2. Sign and sideload using AltStore or Sideloadly.
3. Open Settings → AI Provider → Enter free Gemini API key → Tap Save & Activate → Tap Test Connection.
