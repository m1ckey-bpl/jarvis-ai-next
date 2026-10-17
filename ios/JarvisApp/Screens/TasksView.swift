import SwiftUI

public struct TasksView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var isAddPresented: Bool = false
    @State private var newTitle: String = ""
    @State private var newDate: Date = Date().addingTimeInterval(3600)
    @State private var isRecurring: Bool = false
    @State private var recurrenceRule: RecurrenceRule = .daily

    private var upcomingReminders: [ReminderItem] {
        env.reminders.reminders.filter { !$0.isCompleted }
    }

    private var completedReminders: [ReminderItem] {
        env.reminders.reminders.filter { $0.isCompleted }
    }

    public var body: some View {
        NavigationStack {
            List {
                if upcomingReminders.isEmpty && completedReminders.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    if !upcomingReminders.isEmpty {
                        Section {
                            ForEach(upcomingReminders) { item in
                                reminderRow(item: item)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            try? env.reminders.cancelReminder(id: item.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text("UPCOMING")
                                .font(JarvisTheme.caption())
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                    }

                    if !completedReminders.isEmpty {
                        Section {
                            ForEach(completedReminders) { item in
                                reminderRow(item: item)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            try? env.reminders.cancelReminder(id: item.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text("COMPLETED")
                                .font(JarvisTheme.caption())
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Tasks & Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddPresented = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(JarvisTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $isAddPresented) {
                addReminderSheet
            }
            .jarvisBG()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image(systemName: "checklist")
                .font(.system(size: 54))
                .foregroundColor(JarvisTheme.textTertiary)
            Text("No Active Tasks")
                .font(JarvisTheme.headline())
                .foregroundColor(JarvisTheme.textPrimary)
            Text("Tell JARVIS 'Remind me tomorrow at 9am to...' or tap + to create a reminder.")
                .font(JarvisTheme.callout())
                .foregroundColor(JarvisTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, JarvisTheme.l)
            Spacer(minLength: 40)
        }
    }

    @ViewBuilder
    private func reminderRow(item: ReminderItem) -> some View {
        HStack(spacing: 12) {
            Button {
                try? env.reminders.markCompleted(id: item.id)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.isCompleted ? JarvisTheme.success : JarvisTheme.accent)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(JarvisTheme.body())
                    .foregroundColor(item.isCompleted ? JarvisTheme.textTertiary : JarvisTheme.textPrimary)
                    .strikethrough(item.isCompleted)

                HStack(spacing: 6) {
                    Text(item.scheduledDate, style: .date)
                    Text(item.scheduledDate, style: .time)
                    if item.isRecurring, let rule = item.recurrenceRule {
                        Text("• \(rule.rawValue)")
                            .foregroundColor(JarvisTheme.accent)
                    }
                }
                .font(JarvisTheme.caption())
                .foregroundColor(JarvisTheme.textTertiary)
            }

            Spacer()
        }
        .padding(JarvisTheme.m)
        .glassCard(cornerRadius: JarvisTheme.radiusM)
    }

    private var addReminderSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                JarvisTextField("Reminder title...", text: $newTitle)

                DatePicker("Scheduled Time", selection: $newDate, displayedComponents: [.date, .hourAndMinute])
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textPrimary)
                    .padding(JarvisTheme.m)
                    .glassCard(cornerRadius: JarvisTheme.radiusM)

                Toggle("Recurring", isOn: $isRecurring)
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textPrimary)
                    .padding(JarvisTheme.m)
                    .glassCard(cornerRadius: JarvisTheme.radiusM)

                if isRecurring {
                    Picker("Frequency", selection: $recurrenceRule) {
                        ForEach(RecurrenceRule.allCases, id: \.self) { rule in
                            Text(rule.rawValue).tag(rule)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, JarvisTheme.s)
                }

                JarvisPrimaryButton(title: "Schedule Reminder") {
                    let title = newTitle.trimmingCharacters(in: .whitespaces)
                    guard !title.isEmpty else { return }
                    let item = ReminderItem(
                        title: title,
                        scheduledDate: newDate,
                        isRecurring: isRecurring,
                        recurrenceRule: isRecurring ? recurrenceRule : nil
                    )
                    try? env.reminders.scheduleReminder(item)
                    newTitle = ""
                    isAddPresented = false
                }
                .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding(JarvisTheme.m)
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isAddPresented = false }
                        .foregroundColor(JarvisTheme.textSecondary)
                }
            }
            .jarvisBG()
        }
    }
}
