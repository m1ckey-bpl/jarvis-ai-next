import Foundation

/// Manages the active conversation, including the system prompt and message history.
public final class ConversationContext: ObservableObject {

    @Published public private(set) var messages: [ChatMessage] = []

    public let systemPrompt: String = """
    You are JARVIS, a sophisticated AI personal assistant. You are intelligent, composed, and concise.
    You have access to the user's memory, reminders, calendar, and a set of tools you can call.
    
    Your personality:
    - Speak naturally and conversationally, not robotically
    - Be direct and action-oriented — when asked to do something, do it
    - Be honest about your limitations and what you cannot do
    - Never fabricate information or pretend to have done something you haven't
    - Keep responses appropriately brief unless detail is needed
    - You remember the user's preferences and important facts about their life
    
    Your capabilities include:
    - Answering questions and having conversations
    - Setting reminders and managing tasks
    - Reading and searching the user's memory
    - Drafting emails (with user approval before sending)
    - Checking GitHub repository status
    - Searching the web for information
    
    When executing tasks, always confirm the result. If something fails, say so clearly.
    You do not have unrestricted access to the user's device or accounts — only what they have authorized.
    """

    private let maxMessages = 40
    private let summaryThreshold = 30

    // MARK: - Message management

    public func addUserMessage(_ text: String) {
        messages.append(ChatMessage(role: .user, content: text))
        trimIfNeeded()
    }

    public func addAssistantMessage(_ text: String) {
        messages.append(ChatMessage(role: .assistant, content: text))
    }

    public func addSystemNote(_ text: String) {
        messages.append(ChatMessage(role: .system, content: "[SYSTEM] \(text)"))
    }

    /// Returns messages formatted for a provider call: system prompt first, then recent conversation.
    public func messagesForProvider() -> [ChatMessage] {
        let system = ChatMessage(role: .system, content: systemPrompt)
        let recent = Array(messages.suffix(20))
        return [system] + recent
    }

    public func clear() {
        messages.removeAll()
    }

    public func export() -> String {
        messages.map { "[\($0.role.rawValue.uppercased())] \($0.content)" }
            .joined(separator: "\n\n")
    }

    public var messageCount: Int { messages.count }

    // MARK: - Trim

    private func trimIfNeeded() {
        if messages.count > maxMessages {
            // Keep the most recent messages; drop the oldest non-system ones
            messages = Array(messages.suffix(summaryThreshold))
        }
    }
}
