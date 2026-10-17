import Foundation

/// Groq API provider — OpenAI-compatible, free tier with Llama models.
/// Free tier: llama-3.1-8b-instant — 30 RPM, 6000 RPD, no credit card required.
public final class GroqProvider: AIProvider, @unchecked Sendable {

    public let config: ProviderConfig

    private let session: URLSession
    private static let baseURL = "https://api.groq.com/openai/v1"

    public init(config: ProviderConfig) {
        self.config = config
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: cfg)
    }

    // MARK: - Helpers

    private func apiKey() throws -> String {
        guard let key = KeychainStore.shared.load(key: config.apiKeyRef), !key.isEmpty else {
            throw AIError.invalidCredentials
        }
        return key
    }

    private func buildRequest(messages: [ChatMessage], stream: Bool) throws -> URLRequest {
        let key = try apiKey()
        guard let url = URL(string: "\(Self.baseURL)/chat/completions") else {
            throw AIError.networkError("Invalid Groq URL")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let msgs = messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        let body: [String: Any] = [
            "model": config.model,
            "messages": msgs,
            "stream": stream,
            "max_tokens": 2048
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return req
    }

    // MARK: - AIProvider

    public func sendMessage(_ messages: [ChatMessage]) async throws -> String {
        let req = try buildRequest(messages: messages, stream: false)
        let (data, response) = try await session.data(for: req)
        try mapHTTPStatus(response: response, data: data)

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String
        else { throw AIError.malformedResponse }
        return content
    }

    public func streamMessage(_ messages: [ChatMessage]) async throws -> AsyncThrowingStream<String, Error> {
        let req = try buildRequest(messages: messages, stream: true)
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await self.session.bytes(for: req)
                    try self.mapHTTPStatus(response: response, data: nil)
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { break }
                        guard
                            let data = payload.data(using: .utf8),
                            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let choices = json["choices"] as? [[String: Any]],
                            let delta = choices.first?["delta"] as? [String: Any],
                            let text = delta["content"] as? String
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
        let _ = try await sendMessage([ChatMessage(role: .user, content: "Hi")])
        return true
    }

    public func availableModels() async throws -> [String] {
        let key = try apiKey()
        guard let url = URL(string: "\(Self.baseURL)/models") else {
            throw AIError.networkError("Invalid Groq models URL")
        }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: req)
        try mapHTTPStatus(response: response, data: data)
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let models = json["data"] as? [[String: Any]]
        else { throw AIError.malformedResponse }
        return models.compactMap { $0["id"] as? String }.sorted()
    }

    // MARK: - HTTP status mapping

    private func mapHTTPStatus(response: URLResponse?, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200..<300: return
        case 401: throw AIError.invalidCredentials
        case 404: throw AIError.modelUnavailable(config.model)
        case 429: throw AIError.quotaExceeded
        case 400..<500:
            throw AIError.serverError(http.statusCode, extractMessage(data) ?? "Client error")
        case 500..<600:
            throw AIError.serverError(http.statusCode, extractMessage(data) ?? "Server error")
        default:
            throw AIError.unknown("HTTP \(http.statusCode)")
        }
    }

    private func extractMessage(_ data: Data?) -> String? {
        guard let data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? [String: Any], let msg = error["message"] as? String
        else { return nil }
        return msg
    }
}
