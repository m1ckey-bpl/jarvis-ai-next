import SwiftUI

public struct ProviderSettingsView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedProvider: ProviderID = .gemini
    @State private var apiKeyInput: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: String?
    @State private var availableModels: [String] = []
    @State private var isLoadingModels: Bool = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    JarvisSectionHeader("SELECT PROVIDER")

                    Picker("Provider", selection: $selectedProvider) {
                        Text("Google Gemini").tag(ProviderID.gemini)
                        Text("Groq (Free)").tag(ProviderID.groq)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, JarvisTheme.m)
                    .onChange(of: selectedProvider) {
                        loadExistingKey()
                    }

                    // Key Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API KEY")
                            .font(JarvisTheme.caption())
                            .foregroundColor(JarvisTheme.textTertiary)

                        JarvisTextField("Paste API key here...", text: $apiKeyInput, isSecure: true)

                        if let keyRef = currentConfig?.apiKeyRef,
                           let fp = KeychainStore.shared.fingerprint(key: keyRef) {
                            HStack {
                                Text("Saved:")
                                    .font(JarvisTheme.caption())
                                    .foregroundColor(JarvisTheme.textTertiary)
                                Text(fp)
                                    .font(JarvisTheme.mono())
                                    .foregroundColor(JarvisTheme.accent)
                            }
                        }
                    }
                    .padding(.horizontal, JarvisTheme.m)

                    // Save Button
                    JarvisPrimaryButton(title: "Save & Activate Provider") {
                        saveAndActivate()
                    }
                    .padding(.horizontal, JarvisTheme.m)
                    .disabled(apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty)

                    JarvisSectionHeader("DIAGNOSTICS & TESTING")

                    // Test Connection
                    VStack(spacing: 10) {
                        JarvisButton(title: isTesting ? "Testing..." : "Test Connection", icon: "bolt.fill") {
                            runTest()
                        }
                        .disabled(isTesting || env.catalog.activeProvider == nil)

                        if let res = testResult {
                            Text(res)
                                .font(JarvisTheme.callout())
                                .foregroundColor(res.contains("Success") ? JarvisTheme.success : JarvisTheme.destructive)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(JarvisTheme.s)
                        }

                        JarvisButton(title: isLoadingModels ? "Fetching..." : "List Supported Models", icon: "list.bullet") {
                            fetchModels()
                        }
                        .disabled(isLoadingModels || env.catalog.activeProvider == nil)

                        if !availableModels.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("AVAILABLE MODELS")
                                    .font(JarvisTheme.caption())
                                    .foregroundColor(JarvisTheme.accent)
                                ForEach(availableModels.prefix(8), id: \.self) { m in
                                    Text("• \(m)")
                                        .font(JarvisTheme.mono())
                                        .foregroundColor(JarvisTheme.textSecondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(JarvisTheme.m)
                            .glassCard(cornerRadius: JarvisTheme.radiusM)
                        }
                    }
                    .padding(.horizontal, JarvisTheme.m)
                }
                .padding(.bottom, JarvisTheme.l)
            }
            .navigationTitle("AI Provider Config")
            .navigationBarTitleDisplayMode(.inline)
            .jarvisBG()
            .onAppear {
                if let active = env.catalog.activeConfig {
                    selectedProvider = active.providerID
                }
                loadExistingKey()
            }
        }
    }

    private var currentConfig: ProviderConfig? {
        ProviderCatalog.knownConfigs.first { $0.providerID == selectedProvider }
    }

    private func loadExistingKey() {
        if let config = currentConfig,
           let existing = KeychainStore.shared.load(key: config.apiKeyRef) {
            apiKeyInput = existing
        } else {
            apiKeyInput = ""
        }
    }

    private func saveAndActivate() {
        let key = apiKeyInput.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty, let config = currentConfig else { return }
        do {
            try env.catalog.saveKeyAndActivate(apiKey: key, config: config)
            testResult = "✅ Provider activated! You can now test the connection."
        } catch {
            testResult = "❌ Error saving key: \(error.localizedDescription)"
        }
    }

    private func runTest() {
        isTesting = true
        testResult = nil
        Task {
            guard let provider = env.catalog.activeProvider else {
                await MainActor.run {
                    isTesting = false
                    testResult = "❌ No active provider configured"
                }
                return
            }
            do {
                _ = try await provider.testConnection()
                await MainActor.run {
                    isTesting = false
                    testResult = "✅ Connection Successful! Provider responded properly."
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    testResult = "❌ Connection Failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchModels() {
        isLoadingModels = true
        Task {
            guard let provider = env.catalog.activeProvider else {
                await MainActor.run { isLoadingModels = false }
                return
            }
            do {
                let models = try await provider.availableModels()
                await MainActor.run {
                    isLoadingModels = false
                    availableModels = models
                }
            } catch {
                await MainActor.run {
                    isLoadingModels = false
                    testResult = "❌ Models error: \(error.localizedDescription)"
                }
            }
        }
    }
}
