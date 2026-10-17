import Foundation

// MARK: - Memory Category

public enum MemoryCategory: String, Codable, CaseIterable {
    case fact        = "Fact"
    case preference  = "Preference"
    case goal        = "Goal"
    case date        = "Important Date"
    case summary     = "Conversation Summary"
    case decision    = "Decision"
    case task        = "Task"
    case other       = "Other"

    public var icon: String {
        switch self {
        case .fact:       return "lightbulb"
        case .preference: return "heart"
        case .goal:       return "target"
        case .date:       return "calendar"
        case .summary:    return "text.bubble"
        case .decision:   return "checkmark.seal"
        case .task:       return "checklist"
        case .other:      return "circle.grid.2x2"
        }
    }
}

// MARK: - Memory Record

public struct MemoryRecord: Identifiable, Codable, Equatable {
    public let id: UUID
    public var category: MemoryCategory
    public var content: String
    public var tags: [String]
    public var confidence: Double      // 0.0 – 1.0
    public let timestamp: Date
    public var lastAccessed: Date
    public var isRetained: Bool        // User explicitly wants to keep this

    public init(
        id: UUID = UUID(),
        category: MemoryCategory,
        content: String,
        tags: [String] = [],
        confidence: Double = 1.0,
        timestamp: Date = Date(),
        lastAccessed: Date = Date(),
        isRetained: Bool = false
    ) {
        self.id = id
        self.category = category
        self.content = content
        self.tags = tags
        self.confidence = confidence
        self.timestamp = timestamp
        self.lastAccessed = lastAccessed
        self.isRetained = isRetained
    }
}

// MARK: - Memory Store

/// Persistent memory store backed by a JSON file in Application Support.
/// All mutations are serialized through an actor to prevent data races.
public actor MemoryStore {

    private var records: [MemoryRecord] = []
    private let storeURL: URL

    public init(storeURL: URL? = nil) {
        if let url = storeURL {
            self.storeURL = url
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("ai.jarvis.next", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.storeURL = dir.appendingPathComponent("memory.json")
        }
        // Load existing records synchronously at init
        if let data = try? Data(contentsOf: self.storeURL),
           let loaded = try? JSONDecoder().decode([MemoryRecord].self, from: data) {
            self.records = loaded
        }
    }

    // MARK: - CRUD

    public func save(_ record: MemoryRecord) throws {
        records.removeAll { $0.id == record.id }
        records.append(record)
        try persist()
    }

    public func fetch(id: UUID) -> MemoryRecord? {
        records.first { $0.id == id }
    }

    public func update(_ record: MemoryRecord) throws {
        guard let idx = records.firstIndex(where: { $0.id == record.id }) else { return }
        records[idx] = record
        try persist()
    }

    public func delete(id: UUID) throws {
        records.removeAll { $0.id == id }
        try persist()
    }

    public func allRecords() -> [MemoryRecord] {
        records.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Search

    public func search(query: String, categories: [MemoryCategory]? = nil) -> [MemoryRecord] {
        let q = query.lowercased()
        return records.filter { record in
            guard categories == nil || categories!.contains(record.category) else { return false }
            if q.isEmpty { return true }
            return record.content.lowercased().contains(q)
                || record.tags.contains { $0.lowercased().contains(q) }
        }.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - Maintenance

    public func purgeExpired(olderThan days: Int = 90) throws {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        records.removeAll { !$0.isRetained && $0.lastAccessed < cutoff }
        try persist()
    }

    public func count() -> Int { records.count }

    public func countByCategory() -> [MemoryCategory: Int] {
        Dictionary(grouping: records, by: \.category).mapValues { $0.count }
    }

    // MARK: - Persistence

    private func persist() throws {
        let data = try JSONEncoder().encode(records)
        try data.write(to: storeURL, options: .atomic)
    }
}
