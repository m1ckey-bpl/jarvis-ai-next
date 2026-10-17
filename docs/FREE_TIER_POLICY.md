# FREE TIER POLICY — PROJECT JARVIS

This document details the zero-cost architecture guidelines for JARVIS.

## 1. AI Inference Providers
- **Google Gemini API (Free Tier):**
  - Model: `gemini-1.5-flash`
  - Free Quota: Up to 15 Requests Per Minute (RPM), 1,000,000 Tokens Per Minute (TPM), and 1,500 Requests Per Day.
  - Zero billing account setup required via [Google AI Studio](https://aistudio.google.com/).
- **Groq API (Free Tier Fallback):**
  - Model: `llama-3.1-8b-instant`
  - Ultra-low latency (< 300ms) with generous free tier limits and no credit card required.

## 2. On-Device Services (Zero Cloud Cost)
- **Voice Synthesis:** Native iOS `AVSpeechSynthesizer` (zero API usage, zero quota, high quality local voices).
- **Voice Recognition:** Apple `SFSpeechRecognizer` (free, on-device transcription).
- **Local Notifications:** Native `UNUserNotificationCenter` for task reminders without expensive server push notification infrastructure.
- **Persistence:** Local JSON encrypted storage in the app sandbox and iOS Keychain for credentials.

## 3. Build & CI Infrastructure
- **GitHub Actions:** Public repository hosting provides free unlimited workflow minutes on standard runners (and standard free quota for macOS runners on public repositories).
