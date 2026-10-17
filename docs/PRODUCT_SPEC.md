# PRODUCT SPECIFICATION — PROJECT JARVIS (jarvis-ai-next)

## 1. Product Mission
To provide an autonomous, reliable, and delightful native iOS personal assistant with conversational voice, persistent memory, and live tool execution capabilities on the user's iPhone.

## 2. Core Functional Requirements
- **FR-1 Native SwiftUI App:** Pure Swift/SwiftUI application targeting iOS 17.0+.
- **FR-2 Real-Time Conversational Voice:** Immediate audio capture via SFSpeechRecognizer and natural voice playback via AVSpeechSynthesizer.
- **FR-3 Animated Avatar Face:** Live digital visage responding to agent states (idle, listening, thinking, speaking) with mouth synchronization.
- **FR-4 Multi-Provider AI Engine:** Unified abstraction layer supporting Google Gemini and Groq, with secure in-app API key configuration.
- **FR-5 Persistent Memory:** Structured long-term storage of user preferences, important facts, and conversation context.
- **FR-6 Reminders & Scheduling:** Device-native local notifications scheduled through natural language interpretation.
- **FR-7 Tool Calling Framework:** Structured agent execution loop with approval gates for sensitive actions.
- **FR-8 Unsigned IPA Pipeline:** Automated packaging of ready-to-sideload `.ipa` builds without requiring developer certificates.
