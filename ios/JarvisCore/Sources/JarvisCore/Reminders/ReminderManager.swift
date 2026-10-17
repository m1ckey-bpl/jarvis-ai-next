import Foundation
import UserNotifications

// MARK: - Recurrence

public enum RecurrenceRule: String, Codable, CaseIterable {
    case daily   = "Daily"
    case weekly  = "Weekly"
    case monthly = "Monthly"
}

// MARK: - Reminder Item

public struct ReminderItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var scheduledDate: Date
    public var isRecurring: Bool
    public var recurrenceRule: RecurrenceRule?
    public var isCompleted: Bool
    public let createdAt: Date

    public init(id: UUID = UUID(), title: String, notes: String = "",
                scheduledDate: Date, isRecurring: Bool = false,
                recurrenceRule: RecurrenceRule? = nil,
                isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id; self.title = title; self.notes = notes
        self.scheduledDate = scheduledDate; self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule; self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - Reminder Manager

public final class ReminderManager: ObservableObject {

    @Published public private(set) var reminders: [ReminderItem] = []
    @Published public private(set) var notificationPermission: UNAuthorizationStatus = .notDetermined

    private let storeURL: URL
    private let center = UNUserNotificationCenter.current()

    public init(storeURL: URL? = nil) {
        if let url = storeURL {
            self.storeURL = url
        } else {
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = appSupport.appendingPathComponent("ai.jarvis.next", isDirectory: true)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            self.storeURL = dir.appendingPathComponent("reminders.json")
        }
        load()
        Task { await self.refreshPermissionStatus() }
    }

    // MARK: - Permission

    public func requestPermission() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        await refreshPermissionStatus()
        return granted
    }

    @MainActor
    private func refreshPermissionStatus() async {
        let settings = await center.notificationSettings()
        notificationPermission = settings.authorizationStatus
    }

    // MARK: - Schedule

    public func scheduleReminder(_ item: ReminderItem) throws {
        var item = item
        reminders.removeAll { $0.id == item.id }
        reminders.append(item)
        reminders.sort { $0.scheduledDate < $1.scheduledDate }
        try save()

        // Register local notification
        let content = UNMutableNotificationContent()
        content.title = "JARVIS Reminder"
        content.body = item.title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: item.isRecurring)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        center.add(request) { _ in }
    }

    public func cancelReminder(id: UUID) throws {
        reminders.removeAll { $0.id == id }
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        try save()
    }

    public func markCompleted(id: UUID) throws {
        guard let idx = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[idx].isCompleted = true
        center.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        try save()
    }

    public func pendingReminders() -> [ReminderItem] {
        reminders.filter { !$0.isCompleted && $0.scheduledDate >= Date() }
    }

    // MARK: - Natural language parser

    /// Parses simple phrases like "remind me tomorrow at 9am to study" or
    /// "remind me every Sunday to review projects"
    public func parseNaturalLanguage(_ text: String) -> ReminderItem? {
        let lower = text.lowercased()
        guard lower.contains("remind") else { return nil }

        var title = text
        var date = Date().addingTimeInterval(3600)  // default: 1 hour from now
        var isRecurring = false
        var rule: RecurrenceRule?

        // Extract title (text after "to ")
        if let range = lower.range(of: " to ") {
            title = String(text[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        }

        // Recurrence
        if lower.contains("every day") || lower.contains("daily") {
            isRecurring = true; rule = .daily
        } else if lower.contains("every week") || lower.contains("weekly") || lower.contains("every sunday") || lower.contains("every monday") {
            isRecurring = true; rule = .weekly
        } else if lower.contains("every month") || lower.contains("monthly") {
            isRecurring = true; rule = .monthly
        }

        // Time expressions
        var cal = Calendar.current
        if lower.contains("tomorrow") {
            date = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: Date())) ?? date
        } else if lower.contains("tonight") || lower.contains("today") {
            date = cal.startOfDay(for: Date())
        }

        // Hour extraction
        let hourPatterns = ["9am": 9, "10am": 10, "11am": 11, "12pm": 12, "1pm": 13,
                            "2pm": 14, "3pm": 15, "4pm": 16, "5pm": 17, "6pm": 18,
                            "7pm": 19, "8pm": 20, "9pm": 21, "10pm": 22]
        for (pattern, hour) in hourPatterns where lower.contains(pattern) {
            date = cal.date(bySettingHour: hour, minute: 0, second: 0, of: date) ?? date
            break
        }

        guard !title.isEmpty else { return nil }
        return ReminderItem(title: title, scheduledDate: date, isRecurring: isRecurring, recurrenceRule: rule)
    }

    // MARK: - Persistence

    private func save() throws {
        let data = try JSONEncoder().encode(reminders)
        try data.write(to: storeURL, options: .atomic)
    }

    private func load() {
        guard let data = try? Data(contentsOf: storeURL),
              let loaded = try? JSONDecoder().decode([ReminderItem].self, from: data)
        else { return }
        reminders = loaded
    }
}
