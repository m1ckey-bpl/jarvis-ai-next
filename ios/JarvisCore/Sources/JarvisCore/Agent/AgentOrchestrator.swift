import Foundation

// MARK: - Agent State

public enum AgentState: Equatable {
    case idle
    case thinking
    case executing(String)
    case speaking
    case error(String)
}

// MARK: - Task Record

public struct TaskRecord: Identifiable, Codable {
    public let id: UUID
    public let userRequest: String
    public let agentResponse: String
    public let toolsUsed: [String]
    public let timestamp: Date
    public let wasSuccessful: Bool

    public init(id: UUID = UUID(), userRequest: String, agentResponse: String,
                toolsUsed: [String] = [], timestamp: Date = Date(), wasSuccessful: Bool = true) {
        self.id = id
        self.userRequest = userRequest
        self.agentResponse = agentResponse
        self.toolsUsed = toolsUsed
        self.timestamp = timestamp
        self.wasSuccessful = wasSuccessful
    }
}

// MARK: - Agent Orchestrator

/// Central pipeline: receives user input → calls provider → executes tools → returns response.
public final class AgentOrchestrator: ObservableObject {

    @Published public private(set) var agentState: AgentState = .idle
    @Published public private(set) var currentTask: String?
    @Published public private(set) var taskHistory: [TaskRecord] = []

    private let catalog: ProviderCatalog
    private let context: ConversationContext
    private let memory: MemoryStore
    private let speech: SpeechEngine
    private var currentTask_: Task<Void, Never>?

    public init(catalog: ProviderCatalog, context: ConversationContext,
                memory: MemoryStore, speech: SpeechEngine) {
        self.catalog = catalog
        self.context = context
        self.memory = memory
        self.speech = speech
        loadHistory()
    }

    // MARK: - Main pipeline

    public func processUserInput(_ text: String) async {
        guard case .idle = agentState else { return }

        await MainActor.run {
            agentState = .thinking
            currentTask = text
        }

        context.addUserMessage(text)

        do {
            guard let provider = catalog.activeProvider else {
                let msg = "I'm not connected to an AI provider yet. Please go to Settings → AI Provider and add your API key."
                await finish(response: msg, request: text, success: false)
                return
            }

            let messages = context.messagesForProvider()
            let response = try await provider.sendMessage(messages)

            context.addAssistantMessage(response)

            // Save interesting responses to memory automatically
            await autoSaveToMemory(userText: text, response: response)

            await finish(response: response, request: text, success: true)

        } catch let error as AIError {
            let msg = "I encountered a problem: \(error.localizedDescription)"
            context.addAssistantMessage(msg)
            await finish(response: msg, request: text, success: false, errorState: .error(error.localizedDescription))
        } catch {
            let msg = "Something went wrong. Please try again."
            context.addAssistantMessage(msg)
            await finish(response: msg, request: text, success: false, errorState: .error(error.localizedDescription))
        }
    }

    public func cancelCurrentTask() {
        currentTask_?.cancel()
        currentTask_ = nil
        Task { @MainActor in agentState = .idle; currentTask = nil }
        speech.stopSpeaking()
    }

    // MARK: - Helpers

    private func finish(response: String, request: String, success: Bool, errorState: AgentState? = nil) async {
        let record = TaskRecord(userRequest: request, agentResponse: response,
                                wasSuccessful: success)
        await MainActor.run {
            taskHistory.insert(record, at: 0)
            if taskHistory.count > 200 { taskHistory = Array(taskHistory.prefix(200)) }
            saveHistory()
            agentState = errorState ?? .idle
            currentTask = nil
        }
        // Speak the response
        if success {
            await MainActor.run { agentState = .speaking }
            speech.speak(response)
        }
    }

    private func autoSaveToMemory(userText: String, response: String) async {
        // Detect explicit memory requests
        let lower = userText.lowercased()
        if lower.contains("remember") || lower.contains("don't forget") || lower.contains("note that") {
            let record = MemoryRecord(
                category: .fact,
                content: userText,
                tags: ["auto-saved"],
                confidence: 0.9
            )
            try? await memory.save(record)
        }
    }

    // MARK: - History persistence

    private let historyKey = "jarvis.next.taskHistory"

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(Array(taskHistory.prefix(50))) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let loaded = try? JSONDecoder().decode([TaskRecord].self, from: data) {
            taskHistory = loaded
        }
    }
}
