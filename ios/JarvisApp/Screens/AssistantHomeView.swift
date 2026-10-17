import SwiftUI

public struct AssistantHomeView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    private var faceState: AvatarFaceState {
        if env.speechEngine.isListening { return .listening }
        if env.speechEngine.isSpeaking { return .speaking }

        switch env.orchestrator.agentState {
        case .idle: return .idle
        case .thinking: return .thinking
        case .executing: return .executing
        case .speaking: return .speaking
        case .error: return .error
        }
    }

    private var stateLabel: String {
        if env.speechEngine.isListening { return "LISTENING..." }
        if env.speechEngine.isSpeaking { return "SPEAKING" }

        switch env.orchestrator.agentState {
        case .idle: return "JARVIS ONLINE"
        case .thinking: return "THINKING..."
        case .executing(let task): return "EXECUTING: \(task)"
        case .speaking: return "SPEAKING"
        case .error(let err): return "ERROR: \(err)"
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(env.catalog.activeProvider != nil ? JarvisTheme.success : JarvisTheme.warning)
                        .frame(width: 8, height: 8)
                    Text(env.catalog.activeConfig?.name ?? "No Provider")
                        .font(JarvisTheme.caption())
                        .foregroundColor(JarvisTheme.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .glassCard(cornerRadius: JarvisTheme.radiusS)

                Spacer()

                JarvisStatusBadge(
                    text: faceState == .speaking || faceState == .listening ? "ACTIVE AUDIO" : "STANDBY",
                    color: faceState == .speaking || faceState == .listening ? JarvisTheme.accent : JarvisTheme.textTertiary
                )
            }
            .padding(.horizontal, JarvisTheme.m)
            .padding(.top, JarvisTheme.s)

            Spacer(minLength: 8)

            // Centered Animated Face
            VStack(spacing: 16) {
                Button {
                    // Tap avatar to interrupt speech
                    if env.speechEngine.isSpeaking {
                        env.speechEngine.stopSpeaking()
                    }
                } label: {
                    JarvisFace(
                        state: faceState,
                        jawOpen: env.speechEngine.visemeIntensity
                    )
                }
                .buttonStyle(.plain)

                // Status text & waveform
                VStack(spacing: 6) {
                    Text(stateLabel)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundColor(
                            faceState == .error ? JarvisTheme.destructive :
                            faceState == .thinking ? JarvisTheme.thinking :
                            faceState == .speaking ? JarvisTheme.success :
                            JarvisTheme.accent
                        )

                    WaveformView(
                        intensity: env.speechEngine.isSpeaking || env.speechEngine.isListening ? max(0.2, env.speechEngine.visemeIntensity) : 0.05,
                        isActive: env.speechEngine.isSpeaking || env.speechEngine.isListening
                    )
                }
            }

            Spacer(minLength: 8)

            // Latest Message Preview Card
            if let lastMessage = env.context.messages.last(where: { $0.role == .assistant }) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RESPONSE")
                        .font(JarvisTheme.caption())
                        .foregroundColor(JarvisTheme.accent)
                    ScrollView {
                        Text(lastMessage.content)
                            .font(JarvisTheme.body())
                            .foregroundColor(JarvisTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 90)
                }
                .padding(JarvisTheme.m)
                .glassCard(cornerRadius: JarvisTheme.radiusM)
                .padding(.horizontal, JarvisTheme.m)
                .padding(.bottom, JarvisTheme.s)
            }

            // Input Composer Bar
            HStack(spacing: 10) {
                // Mic Button
                Button {
                    toggleSpeechInput()
                } label: {
                    ZStack {
                        Circle()
                            .fill(env.speechEngine.isListening ? JarvisTheme.destructive : JarvisTheme.surfaceElevated)
                            .frame(width: 46, height: 46)
                            .overlay(
                                Circle().stroke(env.speechEngine.isListening ? Color.white : JarvisTheme.accent.opacity(0.4), lineWidth: 1)
                            )
                        Image(systemName: env.speechEngine.isListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(env.speechEngine.isListening ? .white : JarvisTheme.accent)
                    }
                }
                .buttonStyle(.plain)

                // Text Field
                TextField("Message JARVIS...", text: $inputText)
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                            )
                    )
                    .focused($isInputFocused)
                    .onSubmit {
                        submitText()
                    }

                // Send Button
                Button {
                    submitText()
                } label: {
                    ZStack {
                        Circle()
                            .fill(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.white.opacity(0.1) : JarvisTheme.accent)
                            .frame(width: 46, height: 46)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? JarvisTheme.textTertiary : .black)
                    }
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, JarvisTheme.m)
            .padding(.bottom, JarvisTheme.s)
        }
        .jarvisBG()
        .onAppear {
            env.speechEngine.onTranscription = { transcribed in
                Task {
                    await env.orchestrator.processUserInput(transcribed)
                }
            }
        }
    }

    private func toggleSpeechInput() {
        if env.speechEngine.isListening {
            env.speechEngine.stopListening()
        } else {
            do {
                try env.speechEngine.startListening()
            } catch {
                // fallback or permission alert
            }
        }
    }

    private func submitText() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        isInputFocused = false
        Task {
            await env.orchestrator.processUserInput(text)
        }
    }
}
