import SwiftUI

public struct OnboardingView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var currentPage = 0
    @State private var apiKeyInput: String = ""
    @State private var selectedProvider: ProviderID = .gemini

    public var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                welcomePage
                    .tag(0)
                permissionsPage
                    .tag(1)
                providerPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Footer Navigation
            VStack(spacing: 16) {
                // Page Indicator Dots
                HStack(spacing: 8) {
                    ForEach(0..<3) { idx in
                        Circle()
                            .fill(currentPage == idx ? JarvisTheme.accent : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                if currentPage < 2 {
                    JarvisPrimaryButton(title: "Continue") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                } else {
                    VStack(spacing: 10) {
                        JarvisPrimaryButton(title: "Get Started") {
                            finishOnboarding()
                        }

                        Button("Skip API Setup For Now") {
                            env.completeOnboarding()
                        }
                        .font(JarvisTheme.callout())
                        .foregroundColor(JarvisTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, JarvisTheme.l)
            .padding(.bottom, JarvisTheme.xl)
        }
        .jarvisBG()
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            JarvisFace(state: .idle)

            VStack(spacing: 8) {
                Text("Meet JARVIS")
                    .font(JarvisTheme.largeTitle())
                    .foregroundColor(JarvisTheme.textPrimary)

                Text("Your autonomous personal AI assistant.\nNatural voice, persistent memory, and live intelligence.")
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, JarvisTheme.m)
            }

            Spacer()
        }
    }

    private var permissionsPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(size: 64))
                .foregroundColor(JarvisTheme.accent)

            VStack(spacing: 8) {
                Text("Device Access")
                    .font(JarvisTheme.title())
                    .foregroundColor(JarvisTheme.textPrimary)

                Text("To talk naturally and send scheduled reminders, JARVIS needs your permission.")
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, JarvisTheme.l)
            }

            VStack(spacing: 14) {
                permissionRow(icon: "mic.fill", title: "Microphone", desc: "For real-time voice conversations")
                permissionRow(icon: "waveform.badge.magnifyingglass", title: "Speech Recognition", desc: "To transcribe your speech on-device")
                permissionRow(icon: "bell.fill", title: "Notifications", desc: "To deliver your scheduled reminders")
            }
            .padding(.horizontal, JarvisTheme.m)

            JarvisButton(title: "Grant Permissions") {
                Task {
                    _ = await env.speechEngine.requestPermissions()
                    _ = try? await env.reminders.requestPermission()
                }
            }
            .padding(.horizontal, JarvisTheme.l)

            Spacer()
        }
    }

    private var providerPage: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundColor(JarvisTheme.accent)

            VStack(spacing: 6) {
                Text("Connect AI Engine")
                    .font(JarvisTheme.title())
                    .foregroundColor(JarvisTheme.textPrimary)

                Text("Enter your free Google Gemini API key or Groq API key.")
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Picker("Provider", selection: $selectedProvider) {
                    Text("Google Gemini").tag(ProviderID.gemini)
                    Text("Groq (Free)").tag(ProviderID.groq)
                }
                .pickerStyle(.segmented)

                JarvisTextField("Paste API Key", text: $apiKeyInput, isSecure: true)

                Text("You can also configure or change this anytime in Settings.")
                    .font(JarvisTheme.caption())
                    .foregroundColor(JarvisTheme.textTertiary)
            }
            .padding(.horizontal, JarvisTheme.l)

            Spacer()
        }
    }

    @ViewBuilder
    private func permissionRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(JarvisTheme.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(JarvisTheme.headline())
                    .foregroundColor(JarvisTheme.textPrimary)
                Text(desc)
                    .font(JarvisTheme.caption())
                    .foregroundColor(JarvisTheme.textSecondary)
            }
            Spacer()
        }
        .padding(JarvisTheme.m)
        .glassCard(cornerRadius: JarvisTheme.radiusM)
    }

    private func finishOnboarding() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespaces)
        if !key.isEmpty {
            if let config = ProviderCatalog.knownConfigs.first(where: { $0.providerID == selectedProvider }) {
                try? env.catalog.saveKeyAndActivate(apiKey: key, config: config)
            }
        }
        env.completeOnboarding()
    }
}
