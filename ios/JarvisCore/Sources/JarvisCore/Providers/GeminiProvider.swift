import Foundation

/// Gemini REST API provider.
/// Free tier: gemini-1.5-flash — 15 RPM, 1M TPM, 1500 requests/day.
public final class GeminiProvider: AIProvider, @unchecked Sendable {

    public let config: ProviderConfig

    private let session: URLSession
    private static let baseURL = "https://generativelanguage.googleapis.com/v1beta"

    public init(config: ProviderConfig) {
        self.config = config
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: cfg)
    }

    // MARK: - Request helpers

    private func apiKey() throws -> String {
        guard let key = KeychainStore.shared.load(key: config.apiKeyRef), !key.isEmpty else {
            throw AIError.invalidCredentials
        }
        return key
    }

    private func buildURL(path: String, streaming: Bool = false) throws -> URL {
        let key = try apiKey()
        let action = streaming ? "streamGenerateContent" : "generateContent"
        let raw = "\(Self.baseURL)/models/\(config.model):\(action)?key=\(key)"
        guard let url = URL(string: raw) else { throw AIError.networkError("Invalid URL") }
        return url
    }

    private func buildRequestBody(messages: [ChatMessage]) -> Data? {
        // Build Gemini contents array (system prompt → user turn)
        var contents: [[String: Any]] = []
        for msg in messages where msg.role != .system {
            contents.append([
                "role": msg.role == .user ? "user" : "model",
                "parts": [["text": msg.content]]
            ])
        }
        // System instruction
        var body: [String: Any] = ["contents": contents]
        if let systemMsg = messages.first(where: { $0.role == .system }) {
            body["systemInstruction"] = ["parts": [["text": systemMsg.content]]]
        }
        return try? JSONSerialization.data(withJSONObject: body)
    }

    // MARK: - AIProvider

    public func sendMessage(_ messages: [ChatMessage]) async throws -> String {
        let url = try buildURL(path: "")
        guard let body = buildRequestBody(messages: messages) else {
            throw AIError.malformedResponse
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        let (data, response) = try await session.data(for: req)
        try mapHTTPStatus(response: response, data: data)

        // Parse response
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = json["candidates"] as? [[String: Any]],
            let first = candidates.first,
            let content = first["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw AIError.malformedResponse
        }
        return text
    }

    public func streamMessage(_ messages: [ChatMessage]) async throws -> AsyncThrowingStream<String, Error> {
        let url = try buildURL(path: "", streaming: true)
        guard let body = buildRequestBody(messages: messages) else {
            throw AIError.malformedResponse
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await self.session.bytes(for: req)
                    try self.mapHTTPStatus(response: response, data: nil)
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))
                        guard
                            let data = jsonStr.data(using: .utf8),
                            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let candidates = json["candidates"] as? [[String: Any]],
                            let content = candidates.first?["content"] as? [String: Any],
                            let parts = content["parts"] as? [[String: Any]],
                            let text = parts.first?["text"] as? String
                        else { continue }
                        continuation.yield(text)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func testConnection() async throws -> Bool {
        let probe = [ChatMessage(role: .user, content: "Hi")]
        let _ = try await sendMessage(probe)
        return true
    }

    public func availableModels() async throws -> [String] {
        let key = try apiKey()
        guard let url = URL(string: "\(Self.baseURL)/models?key=\(key)") else {
            throw AIError.networkError("Invalid models URL")
        }
        let (data, response) = try await session.data(from: url)
        try mapHTTPStatus(response: response, data: data)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let models = json["models"] as? [[String: Any]]
        else { throw AIError.malformedResponse }
        return models.compactMap { $0["name"] as? String }
            .filter { $0.contains("gemini") }
            .map { $0.replacingOccurrences(of: "models/", with: "") }
    }

    // MARK: - HTTP status mapping

    private func mapHTTPStatus(response: URLResponse?, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200..<300: return
        case 400:
            let msg = extractErrorMessage(data) ?? "Invalid request"
            if msg.lowercased().contains("api key") { throw AIError.invalidCredentials }
            throw AIError.serverError(400, msg)
        case 401, 403:
            throw AIError.invalidCredentials
        case 404:
            throw AIError.modelUnavailable(config.model)
        case 429:
            throw AIError.quotaExceeded
        case 500..<600:
            throw AIError.serverError(http.statusCode, extractErrorMessage(data) ?? "Server error")
        default:
            throw AIError.unknown("HTTP \(http.statusCode)")
        }
    }

    private func extractErrorMessage(_ data: Data?) -> String? {
        guard let data else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        if let error = json["error"] as? [String: Any], let msg = error["message"] as? String { return msg }
        return nil
    }
}
