import SwiftUI

// MARK: - Primary Action Button

public struct JarvisPrimaryButton: View {
    public let title: String
    public let icon: String?
    public let action: () -> Void

    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(JarvisTheme.headline())
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [JarvisTheme.accent, Color(red: 0.0, green: 0.7, blue: 0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Secondary Glass Button

public struct JarvisButton: View {
    public let title: String
    public let icon: String?
    public let isDestructive: Bool
    public let action: () -> Void

    public init(title: String, icon: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                }
                Text(title)
                    .font(JarvisTheme.body())
            }
            .foregroundColor(isDestructive ? JarvisTheme.destructive : JarvisTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                    .fill(isDestructive ? JarvisTheme.destructive.opacity(0.12) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                            .stroke(isDestructive ? JarvisTheme.destructive.opacity(0.3) : Color.white.opacity(0.12), lineWidth: 0.8)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Status Badge

public struct JarvisStatusBadge: View {
    public let text: String
    public let color: Color

    public init(text: String, color: Color) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(text)
                .font(JarvisTheme.caption())
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(
                    Capsule().stroke(color.opacity(0.25), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Section Header

public struct JarvisSectionHeader: View {
    public let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title.uppercased())
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .tracking(1.2)
            .foregroundColor(JarvisTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, JarvisTheme.m)
            .padding(.top, JarvisTheme.m)
            .padding(.bottom, JarvisTheme.xs)
    }
}

// MARK: - Text Field

public struct JarvisTextField: View {
    public let placeholder: String
    @Binding public var text: String
    public var isSecure: Bool

    public init(_ placeholder: String, text: Binding<String>, isSecure: Bool = false) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
    }

    public var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(JarvisTheme.body())
        .foregroundColor(JarvisTheme.textPrimary)
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
                )
        )
    }
}
