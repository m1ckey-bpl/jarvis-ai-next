import SwiftUI

public struct MemoryCenterView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var records: [MemoryRecord] = []
    @State private var searchText: String = ""
    @State private var isAddSheetPresented: Bool = false
    @State private var newContent: String = ""
    @State private var newCategory: MemoryCategory = .fact

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(JarvisTheme.textTertiary)
                    TextField("Search memories...", text: $searchText)
                        .font(JarvisTheme.body())
                        .foregroundColor(JarvisTheme.textPrimary)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(JarvisTheme.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 42)
                .background(
                    RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .padding(.horizontal, JarvisTheme.m)
                .padding(.vertical, JarvisTheme.s)

                if filteredRecords.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            memoryRow(record: record)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteRecord(id: record.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Memory Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(JarvisTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $isAddSheetPresented) {
                addMemorySheet
            }
            .jarvisBG()
            .onAppear {
                loadRecords()
            }
        }
    }

    private var filteredRecords: [MemoryRecord] {
        if searchText.isEmpty {
            return records
        }
        let q = searchText.lowercased()
        return records.filter { $0.content.lowercased().contains(q) || $0.category.rawValue.lowercased().contains(q) }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 54))
                .foregroundColor(JarvisTheme.textTertiary)
            Text("No Memories Stored")
                .font(JarvisTheme.headline())
                .foregroundColor(JarvisTheme.textPrimary)
            Text("As you speak with JARVIS, important facts and preferences will be remembered here.")
                .font(JarvisTheme.callout())
                .foregroundColor(JarvisTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, JarvisTheme.l)
            Spacer()
        }
    }

    @ViewBuilder
    private func memoryRow(record: MemoryRecord) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(record.category.rawValue, systemImage: record.category.icon)
                    .font(JarvisTheme.caption())
                    .foregroundColor(JarvisTheme.accent)
                Spacer()
                Text(record.timestamp, style: .date)
                    .font(JarvisTheme.caption())
                    .foregroundColor(JarvisTheme.textTertiary)
            }

            Text(record.content)
                .font(JarvisTheme.body())
                .foregroundColor(JarvisTheme.textPrimary)

            if !record.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(record.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(JarvisTheme.caption())
                            .foregroundColor(JarvisTheme.textTertiary)
                    }
                }
            }
        }
        .padding(JarvisTheme.m)
        .glassCard(cornerRadius: JarvisTheme.radiusM)
    }

    private var addMemorySheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Category", selection: $newCategory) {
                    ForEach(MemoryCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(JarvisTheme.m)
                .glassCard(cornerRadius: JarvisTheme.radiusM)

                TextEditor(text: $newContent)
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .padding(JarvisTheme.m)
                    .frame(height: 140)
                    .glassCard(cornerRadius: JarvisTheme.radiusM)

                JarvisPrimaryButton(title: "Save Memory") {
                    saveNewMemory()
                }
                .disabled(newContent.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()
            }
            .padding(JarvisTheme.m)
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isAddSheetPresented = false
                    }
                    .foregroundColor(JarvisTheme.textSecondary)
                }
            }
            .jarvisBG()
        }
    }

    private func loadRecords() {
        Task {
            let loaded = await env.memoryStore.allRecords()
            await MainActor.run {
                self.records = loaded
            }
        }
    }

    private func saveNewMemory() {
        let content = newContent.trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return }
        let record = MemoryRecord(category: newCategory, content: content)
        Task {
            try? await env.memoryStore.save(record)
            await MainActor.run {
                newContent = ""
                isAddSheetPresented = false
                loadRecords()
            }
        }
    }

    private func deleteRecord(id: UUID) {
        Task {
            try? await env.memoryStore.delete(id: id)
            await MainActor.run {
                loadRecords()
            }
        }
    }
}
