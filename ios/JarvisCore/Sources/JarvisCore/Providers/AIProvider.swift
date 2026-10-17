import Foundation

// MARK: - Chat Message

/// A single message in a conversation.
public struct ChatMessage: Identifiable, Codable, Equatable {
    public let id: UUID
    public let role: Role
    public let content: String
    public let timestamp: Date

    public enum Role: String, Codable {
        case system, user, assistant
    }

    public init(id: UUID = UUID(), role: Role, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - Provider Config

/// Configuration for a single AI provider instance.
public struct ProviderConfig: Codable, Equatable {
    public let providerID: ProviderID
    public let name: String
    public let model: String
    public let endpoint: String
    public let apiKeyRef: String   // Keychain key name — never store the key itself here
    public var isActive: Bool

    public init(providerID: ProviderID, name: String, model: String, endpoint: String, apiKeyRef: String, isActive: Bool = false) {
        self.providerID = providerID
        self.name = name
        self.model = model
        self.endpoint = endpoint
        self.apiKeyRef = apiKeyRef
        self.isActive = isActive
    }
}

// MARK: - Provider ID

public enum ProviderID: String, Codable, CaseIterable {
    case gemini
    case groq
    case openai
    case local
}

// MARK: - AI Error

public enum AIError: Error, LocalizedError {
    case invalidCredentials
    case modelUnavailable(String)
    case quotaExceeded
    case networkError(String)
    case timeout
    case serverError(Int, String)
    case malformedResponse
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid API key. Check your credentials in Settings → AI Provider."
        case .modelUnavailable(let model):
            return "Model '\(model)' is not available for your API key. Try 'List models' to see available options."
        case .quotaExceeded:
            return "API quota exceeded. Wait and try again, or switch to a different provider."
        case .networkError(let detail):
            return "Network error: \(detail)"
        case .timeout:
            return "Request timed out. Check your connection and try again."
        case .serverError(let code, let message):
            return "Server error \(code): \(message)"
        case .malformedResponse:
            return "Received an unexpected response format from the provider."
        case .unknown(let detail):
            return "Unexpected error: \(detail)"
        }
    }
}

// MARK: - AI Provider Protocol

/// Abstraction layer for any AI text-generation provider.
public protocol AIProvider: Sendable {
    /// The configuration this provider was created with.
    var config: ProviderConfig { get }

    /// Send a list of messages and receive a complete response.
    func sendMessage(_ messages: [ChatMessage]) async throws -> String

    /// Send a list of messages and receive a streaming response.
    func streamMessage(_ messages: [ChatMessage]) async throws -> AsyncThrowingStream<String, Error>

    /// Verify credentials and connectivity. Returns true on success.
    func testConnection() async throws -> Bool

    /// List models available for the configured API key.
    func availableModels() async throws -> [String]
}
