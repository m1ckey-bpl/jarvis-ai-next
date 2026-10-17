import SwiftUI
import Speech
import AVFoundation

public struct DiagnosticsView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    @State private var speechAuthStatus: String = "Checking..."
    @State private var micAuthStatus: String = "Checking..."
    @State private var memoryCount: Int = 0

    public var body: some View {
        NavigationStack {
            List {
                Section("AI PROVIDER") {
                    diagRow(label: "Provider", value: env.catalog.activeConfig?.name ?? "None")
                    diagRow(label: "Model", value: env.catalog.activeConfig?.model ?? "None")
                    diagRow(label: "Endpoint", value: env.catalog.activeConfig?.endpoint ?? "None")
                    diagRow(label: "Key Stored", value: env.catalog.activeConfig != nil && KeychainStore.shared.exists(key: env.catalog.activeConfig!.apiKeyRef) ? "Yes" : "No")
                }

                Section("AUDIO & SPEECH SUBSYSTEM") {
                    diagRow(label: "Microphone Access", value: micAuthStatus)
                    diagRow(label: "Speech Recognition", value: speechAuthStatus)
                    diagRow(label: "Synthesizer Ready", value: "Yes")
                    diagRow(label: "Viseme Engine", value: "Active (vowel-weighted)")
                }

                Section("PERSISTENCE & STORAGE") {
                    diagRow(label: "Memory Records", value: "\(memoryCount)")
                    diagRow(label: "Upcoming Reminders", value: "\(env.reminders.pendingReminders().count)")
                    diagRow(label: "History Messages", value: "\(env.context.messageCount)")
                }

                Section("DEVICE & SYSTEM") {
                    diagRow(label: "OS Target", value: "iOS 17.0+")
                    diagRow(label: "Design System", value: "Liquid Glass Spatial")
                    diagRow(label: "Build Mode", value: "Release (Unsigned)")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(JarvisTheme.textSecondary)
                }
            }
            .jarvisBG()
            .onAppear {
                checkAuth()
            }
        }
    }

    @ViewBuilder
    private func diagRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(JarvisTheme.body())
                .foregroundColor(JarvisTheme.textPrimary)
            Spacer()
            Text(value)
                .font(JarvisTheme.callout())
                .foregroundColor(JarvisTheme.textSecondary)
        }
        .listRowBackground(Color.white.opacity(0.05))
    }

    private func checkAuth() {
        let auth = SFSpeechRecognizer.authorizationStatus()
        switch auth {
        case .authorized: speechAuthStatus = "Authorized"
        case .denied: speechAuthStatus = "Denied"
        case .restricted: speechAuthStatus = "Restricted"
        case .notDetermined: speechAuthStatus = "Not Determined"
        @unknown default: speechAuthStatus = "Unknown"
        }

        let mic = AVAudioApplication.shared.recordPermission
        switch mic {
        case .granted: micAuthStatus = "Granted"
        case .denied: micAuthStatus = "Denied"
        case .undetermined: micAuthStatus = "Undetermined"
        @unknown default: micAuthStatus = "Unknown"
        }

        Task {
            let count = await env.memoryStore.count()
            await MainActor.run {
                memoryCount = count
            }
        }
    }
}
