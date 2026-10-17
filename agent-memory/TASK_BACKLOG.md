# TASK BACKLOG — jarvis-ai-next

**Legend:** `DONE` · `IMPL` (implemented, unverified) · `WIP` · `TODO` · `BLOCKED`
**Priority:** P0=release gate · P1=important · P2=nice-to-have

---

## Milestones

| # | Milestone | Status |
|---|---|---|
| 1 | Repository + foundation files | DONE |
| 2 | iOS compilation (first CI green build) | WIP |
| 3 | Premium visual identity + all screens | IMPL |
| 4 | Avatar + lip sync | IMPL |
| 5 | AI provider integration | IMPL |
| 6 | Real-time voice | IMPL |
| 7 | Persistent memory | IMPL |
| 8 | Agent + tool execution | IMPL |
| 9 | Reminders + notifications | IMPL |
| 10 | Integrations (Gmail, GitHub, Calendar) | IMPL |
| 11 | Automated tests | IMPL (backend); TODO (Swift) |
| 12 | Unsigned IPA | BLOCKED (needs CI green) |
| 13 | Final audit | TODO |

---

## Immediate Tasks (P0)

| ID | Task | Priority | Status | Blocked by |
|---|---|---|---|---|
| T1 | Push all files to GitHub + trigger CI | P0 | TODO | — |
| T2 | Fix any Swift compilation errors from CI run | P0 | TODO | T1 |
| T3 | Fix any pbxproj issues (regenerate if needed) | P0 | TODO | T2 |
| T4 | Produce unsigned IPA from green CI | P0 | TODO | T2 |

## User-Action Tasks (P1)

| ID | Task | Priority | Status | Blocked by |
|---|---|---|---|---|
| U1 | User provides Gemini API key | P1 | BLOCKED | User |
| U2 | User installs IPA and runs acceptance checklist | P1 | BLOCKED | T4 + user signing |
| U3 | User tests voice input/output on device | P1 | BLOCKED | U2 |

## Implementation Tasks (P1)

| ID | Task | Priority | Status |
|---|---|---|---|
| T5 | Add Swift test target to pbxproj | P1 | TODO |
| T6 | Create INTERACTION_AUDIT.md (every button documented) | P1 | TODO |
| T7 | Add app icon PNG (generated or designed) | P1 | TODO |
| T8 | Run backend pytest locally + record results | P1 | TODO |
| T9 | Add REQUIREMENTS_MATRIX.md | P1 | TODO |

## Enhancement Tasks (P2)

| ID | Task | Priority | Status |
|---|---|---|---|
| T10 | Live Gmail OAuth round-trip | P2 | TODO |
| T11 | Memory export/import (JSON download) | P2 | TODO |
| T12 | More recurring-reminder edge cases | P2 | TODO |
| T13 | Widget (iOS WidgetKit extension) | P2 | TODO |
| T14 | Gemini Live API (streaming audio I/O) | P2 | TODO |

---

## Acceptance Criteria for v1.0.0

- [ ] CI iOS workflow runs green
- [ ] Unsigned IPA produced and verified
- [ ] All screens navigate without crash
- [ ] No buttons are hidden behind tab bar
- [ ] API key can be entered, saved, and tested
- [ ] Voice input captures speech
- [ ] Voice output speaks response
- [ ] Avatar mouth moves during speech
- [ ] Memory records persist across app restart
- [ ] Reminder fires as local notification
