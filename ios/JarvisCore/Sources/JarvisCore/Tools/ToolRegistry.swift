import Foundation

// MARK: - Tool Types

public enum RiskLevel: String, Codable {
    case low, medium, high
}

public struct ToolParameter: Codable {
    public let name: String
    public let type: String      // "string", "number", "boolean"
    public let description: String
    public let isRequired: Bool
}

public struct Tool: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String
    public let parameters: [ToolParameter]
    public let requiresConfirmation: Bool
    public let riskLevel: RiskLevel
}

public struct ToolResult {
    public let success: Bool
    public let output: String
    public let error: String?
    public init(success: Bool, output: String, error: String? = nil) {
        self.success = success; self.output = output; self.error = error
    }
}

// MARK: - Tool Registry

/// Registry of all available tools JARVIS can call.
/// High-risk tools require user confirmation before execution.
public final class ToolRegistry {

    public static let shared = ToolRegistry()

    private var tools: [String: Tool] = [:]

    private init() {
        registerBuiltins()
    }

    public func tool(named name: String) -> Tool? { tools[name] }
    public var allTools: [Tool] { Array(tools.values).sorted { $0.name < $1.name } }

    // MARK: - Built-in tools

    private func registerBuiltins() {
        register(Tool(id: "set_reminder", name: "Set Reminder",
                      description: "Creates a reminder that fires as a local notification.",
                      parameters: [
                        .init(name: "title", type: "string", description: "What to be reminded of", isRequired: true),
                        .init(name: "datetime", type: "string", description: "ISO8601 date/time string", isRequired: true),
                        .init(name: "recurrence", type: "string", description: "daily|weekly|monthly or empty", isRequired: false)
                      ], requiresConfirmation: false, riskLevel: .low))

        register(Tool(id: "search_memory", name: "Search Memory",
                      description: "Searches the user's personal memory store.",
                      parameters: [
                        .init(name: "query", type: "string", description: "Keywords to search", isRequired: true)
                      ], requiresConfirmation: false, riskLevel: .low))

        register(Tool(id: "save_memory", name: "Save to Memory",
                      description: "Saves a fact or note to the user's memory.",
                      parameters: [
                        .init(name: "content", type: "string", description: "The fact or note to remember", isRequired: true),
                        .init(name: "category", type: "string", description: "fact|preference|goal|date|decision|task", isRequired: false)
                      ], requiresConfirmation: false, riskLevel: .low))

        register(Tool(id: "delete_memory", name: "Delete Memory",
                      description: "Deletes a memory record by ID.",
                      parameters: [
                        .init(name: "id", type: "string", description: "UUID of the memory record", isRequired: true)
                      ], requiresConfirmation: true, riskLevel: .medium))

        register(Tool(id: "send_email", name: "Send Email",
                      description: "Sends an email via Gmail (requires OAuth authorization).",
                      parameters: [
                        .init(name: "to", type: "string", description: "Recipient email address", isRequired: true),
                        .init(name: "subject", type: "string", description: "Email subject", isRequired: true),
                        .init(name: "body", type: "string", description: "Email body text", isRequired: true)
                      ], requiresConfirmation: true, riskLevel: .high))

        register(Tool(id: "search_web", name: "Web Search",
                      description: "Searches the web for current information.",
                      parameters: [
                        .init(name: "query", type: "string", description: "Search query", isRequired: true)
                      ], requiresConfirmation: false, riskLevel: .low))

        register(Tool(id: "get_calendar_events", name: "Get Calendar Events",
                      description: "Reads upcoming events from Apple Calendar (requires permission).",
                      parameters: [
                        .init(name: "days", type: "number", description: "Number of days ahead to look", isRequired: false)
                      ], requiresConfirmation: false, riskLevel: .low))
    }

    private func register(_ tool: Tool) {
        tools[tool.id] = tool
    }
}
