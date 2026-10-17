import Foundation
#if canImport(Combine)
import Combine
#endif

/// Manages AI provider configuration and the active provider instance.
public final class ProviderCatalog: ObservableObject {

    public static let shared = ProviderCatalog()

    @Published public private(set) var activeProvider: (any AIProvider)?
    @Published public private(set) var activeConfig: ProviderConfig?
    @Published public private(set) var lastTestResult: String?

    private let defaultsKey = "jarvis.next.activeProviderConfig"

    private init() {
        loadSavedConfig()
    }

    // MARK: - Built-in templates

    public static let knownConfigs: [ProviderConfig] = [
        ProviderConfig(
            providerID: .gemini,
            name: "Google Gemini",
            model: "gemini-1.5-flash",
            endpoint: "https://generativelanguage.googleapis.com/v1beta",
            apiKeyRef: "ai.jarvis.next.gemini.apiKey"
        ),
        ProviderConfig(
            providerID: .groq,
            name: "Groq (Free)",
            model: "llama-3.1-8b-instant",
            endpoint: "https://api.groq.com/openai/v1",
            apiKeyRef: "ai.jarvis.next.groq.apiKey"
        )
    ]

    // MARK: - Activation

    /// Activate a provider with the given config, saving to UserDefaults.
    public func activate(config: ProviderConfig) {
        var cfg = config
        cfg.isActive = true
        activeConfig = cfg
        activeProvider = makeProvider(config: cfg)
        saveConfig(cfg)
        lastTestResult = nil
    }

    /// Save the API key to Keychain and activate the provider.
    public func saveKeyAndActivate(apiKey: String, config: ProviderConfig) throws {
        try KeychainStore.shared.save(key: config.apiKeyRef, value: apiKey)
        activate(config: config)
    }

    /// Run a connection test. Updates lastTestResult.
    public func runConnectionTest() async {
        guard let provider = activeProvider else {
            await MainActor.run { lastTestResult = "❌ No provider configured" }
            return
        }
        do {
            _ = try await provider.testConnection()
            await MainActor.run { lastTestResult = "✅ Connected successfully" }
        } catch {
            await MainActor.run { lastTestResult = "❌ \(error.localizedDescription)" }
        }
    }

    // MARK: - Persistence

    private func saveConfig(_ config: ProviderConfig) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func loadSavedConfig() {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let config = try? JSONDecoder().decode(ProviderConfig.self, from: data)
        else { return }
        activeConfig = config
        activeProvider = makeProvider(config: config)
    }

    // MARK: - Factory

    private func makeProvider(config: ProviderConfig) -> (any AIProvider) {
        switch config.providerID {
        case .gemini: return GeminiProvider(config: config)
        case .groq:   return GroqProvider(config: config)
        default:      return GeminiProvider(config: config)
        }
    }
}
