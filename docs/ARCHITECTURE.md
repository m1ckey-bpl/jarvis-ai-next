# ARCHITECTURE — PROJECT JARVIS (jarvis-ai-next)

## System Overview

JARVIS is built as a native iOS application written entirely in Swift and SwiftUI, targeting iOS 17.0+. It features a layered modular architecture with clear separation of concerns:

```
┌────────────────────────────────────────────────────────┐
│                      JarvisApp                         │
│   (SwiftUI Views, Liquid Glass Design, Screens, App)   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      JarvisCore                        │
│                                                        │
│  ┌──────────────────┐  ┌────────────────────────────┐  │
│  │ AgentOrchestrator│  │      SpeechEngine          │  │
│  │ (Task Loop)      │  │ (SFSpeech + AVSynthesizer) │  │
│  └────────┬─────────┘  └─────────────┬──────────────┘  │
│           │                          │                 │
│  ┌────────▼─────────┐  ┌─────────────▼──────────────┐  │
│  │   AIProvider     │  │       VisemeEngine         │  │
│  │ (Gemini / Groq)  │  │  (Lip Sync Phoneme Math)   │  │
│  └────────┬─────────┘  └────────────────────────────┘  │
│           │                                            │
│  ┌────────▼─────────┐  ┌────────────────────────────┐  │
│  │   MemoryStore    │  │      ReminderManager       │  │
│  │ (Actor JSON DB)  │  │ (UNUserNotificationCenter) │  │
│  └──────────────────┘  └────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

## Core Modules

### 1. JarvisApp (UI Layer)
- **RootView & MainShell:** Tab-based navigation where content is cleanly separated from the navigation bar (siblings in a vertical stack to prevent hidden controls).
- **JarvisFace:** Custom SwiftUI-rendered digital visage featuring glowing optics, thinking scanlines, and audio-reactive 7-bar mouth for lip synchronization.
- **WaveformView:** 24-bar audio-frequency visualizer reacting to spoken intensity.
- **Screens:** AssistantHome, MemoryCenter, Tasks, Integrations, Settings, ProviderSettings, ConversationHistory, Diagnostics, Onboarding.

### 2. JarvisCore Engine
- **AIProvider Protocol:** Clean abstraction supporting Google Gemini (`gemini-1.5-flash`) and Groq (`llama-3.1-8b-instant`).
- **SpeechEngine:** On-device audio processing utilizing `SFSpeechRecognizer` for input and `AVSpeechSynthesizer` for voice generation. It exposes `visemeIntensity` driven by utterance range callbacks.
- **VisemeEngine:** Vowel-weighted phoneme algorithm calculating mouth aperture from words.
- **MemoryStore:** Actor-isolated JSON persistent storage managing user preferences, facts, and conversation history.
- **ReminderManager:** Bridges natural language scheduling to Apple's `UNUserNotificationCenter` local notifications.
- **KeychainStore:** Native iOS Security framework wrapper storing API keys securely without plain-text disk storage.
