import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var isProviderPresented: Bool = false
    @State private var isDiagnosticsPresented: Bool = false
    @State private var isHistoryPresented: Bool = false
    @State private var showClearAlert: Bool = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // AI Engine section
                    JarvisSectionHeader("INTELLIGENCE ENGINE")
                    Button {
                        isProviderPresented = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(env.catalog.activeConfig?.name ?? "Configure AI Provider")
                                    .font(JarvisTheme.headline())
                                    .foregroundColor(JarvisTheme.textPrimary)
                                Text(env.catalog.activeConfig?.model ?? "Tap to setup Gemini or Groq API")
                                    .font(JarvisTheme.caption())
                                    .foregroundColor(JarvisTheme.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                        .padding(JarvisTheme.m)
                        .glassCard(cornerRadius: JarvisTheme.radiusM)
                    }
                    .buttonStyle(.plain)

                    // Conversation & History
                    JarvisSectionHeader("CONVERSATION")
                    Button {
                        isHistoryPresented = true
                    } label: {
                        HStack {
                            Label("Conversation History", systemImage: "clock.arrow.circlepath")
                                .font(JarvisTheme.body())
                                .foregroundColor(JarvisTheme.textPrimary)
                            Spacer()
                            Text("\(env.context.messageCount) messages")
                                .font(JarvisTheme.caption())
                                .foregroundColor(JarvisTheme.textTertiary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                        .padding(JarvisTheme.m)
                        .glassCard(cornerRadius: JarvisTheme.radiusM)
                    }
                    .buttonStyle(.plain)

                    // Diagnostics
                    JarvisSectionHeader("SYSTEM & HEALTH")
                    Button {
                        isDiagnosticsPresented = true
                    } label: {
                        HStack {
                            Label("Diagnostics & Telemetry", systemImage: "waveform.path.ecg")
                                .font(JarvisTheme.body())
                                .foregroundColor(JarvisTheme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                        .padding(JarvisTheme.m)
                        .glassCard(cornerRadius: JarvisTheme.radiusM)
                    }
                    .buttonStyle(.plain)

                    // Reset Data
                    JarvisSectionHeader("DATA MANAGEMENT")
                    JarvisButton(title: "Clear Memory & Reset", icon: "trash", isDestructive: true) {
                        showClearAlert = true
                    }

                    // Version footer
                    VStack(spacing: 4) {
                        Text("PROJECT JARVIS • Native iOS")
                            .font(JarvisTheme.caption())
                            .foregroundColor(JarvisTheme.textTertiary)
                        Text("Version 1.0.0 (Build 1)")
                            .font(JarvisTheme.caption())
                            .foregroundColor(JarvisTheme.textTertiary)
                    }
                    .padding(.top, JarvisTheme.l)
                }
                .padding(.horizontal, JarvisTheme.m)
                .padding(.bottom, JarvisTheme.l)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isProviderPresented) {
                ProviderSettingsView()
            }
            .sheet(isPresented: $isDiagnosticsPresented) {
                DiagnosticsView()
            }
            .sheet(isPresented: $isHistoryPresented) {
                ConversationHistoryView()
            }
            .alert("Reset All Data?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    env.context.clear()
                    Task {
                        try? await env.memoryStore.purgeExpired(olderThan: 0)
                    }
                }
            } message: {
                Text("This will clear active conversation history and memory records.")
            }
            .jarvisBG()
        }
    }
}
