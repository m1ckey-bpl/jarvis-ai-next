import SwiftUI

public struct ConversationHistoryView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            Group {
                if env.context.messages.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 48))
                            .foregroundColor(JarvisTheme.textTertiary)
                        Text("No Messages Yet")
                            .font(JarvisTheme.headline())
                            .foregroundColor(JarvisTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(env.context.messages) { msg in
                                chatBubble(for: msg)
                            }
                        }
                        .padding(JarvisTheme.m)
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(JarvisTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: env.context.export()) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15))
                            .foregroundColor(JarvisTheme.accent)
                    }
                    .disabled(env.context.messages.isEmpty)
                }
            }
            .jarvisBG()
        }
    }

    @ViewBuilder
    private func chatBubble(for msg: ChatMessage) -> some View {
        HStack {
            if msg.role == .user {
                Spacer(minLength: 40)
            }

            VStack(alignment: msg.role == .user ? .trailing : .leading, spacing: 4) {
                Text(msg.role == .user ? "YOU" : "JARVIS")
                    .font(JarvisTheme.caption())
                    .foregroundColor(msg.role == .user ? JarvisTheme.accent : JarvisTheme.textTertiary)

                Text(msg.content)
                    .font(JarvisTheme.body())
                    .foregroundColor(JarvisTheme.textPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                            .fill(msg.role == .user ? JarvisTheme.accent.opacity(0.18) : Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                                    .stroke(msg.role == .user ? JarvisTheme.accent.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 0.8)
                            )
                    )

                Text(msg.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(JarvisTheme.textTertiary)
            }

            if msg.role != .user {
                Spacer(minLength: 40)
            }
        }
    }
}
