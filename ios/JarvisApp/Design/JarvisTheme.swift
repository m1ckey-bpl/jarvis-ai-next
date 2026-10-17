import SwiftUI

// MARK: - Color palette & typography

enum JarvisTheme {
    // Colors
    static let background        = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let surface           = Color(red: 0.08, green: 0.09, blue: 0.12)
    static let surfaceElevated   = Color(red: 0.12, green: 0.13, blue: 0.18)
    static let accent            = Color(red: 0.00, green: 0.85, blue: 1.00)    // #00D9FF
    static let accentDim         = Color(red: 0.00, green: 0.55, blue: 0.75)
    static let accentGlow        = Color(red: 0.00, green: 0.85, blue: 1.00).opacity(0.25)
    static let textPrimary       = Color.white
    static let textSecondary     = Color(white: 0.70)
    static let textTertiary      = Color(white: 0.42)
    static let destructive       = Color(red: 1.00, green: 0.30, blue: 0.30)
    static let success           = Color(red: 0.20, green: 0.90, blue: 0.50)
    static let warning           = Color(red: 1.00, green: 0.75, blue: 0.00)
    static let thinking          = Color(red: 1.00, green: 0.60, blue: 0.10)

    // Typography
    static func largeTitle() -> Font { .system(size: 34, weight: .bold,     design: .rounded) }
    static func title()      -> Font { .system(size: 28, weight: .semibold, design: .rounded) }
    static func title2()     -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func headline()   -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func body()       -> Font { .system(size: 16, weight: .regular,  design: .rounded) }
    static func callout()    -> Font { .system(size: 14, weight: .regular,  design: .rounded) }
    static func caption()    -> Font { .system(size: 11, weight: .medium,   design: .rounded) }
    static func mono()       -> Font { .system(size: 13, weight: .regular,  design: .monospaced) }

    // Spacing
    static let xs: CGFloat = 4
    static let s:  CGFloat = 8
    static let m:  CGFloat = 16
    static let l:  CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // Radii
    static let radiusS:  CGFloat = 8
    static let radiusM:  CGFloat = 12
    static let radiusL:  CGFloat = 16
    static let radiusXL: CGFloat = 24
}

// MARK: - Glass card modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = JarvisTheme.radiusL
    var opacity: Double = 0.07

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(opacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = JarvisTheme.radiusL, opacity: Double = 0.07) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity))
    }

    func jarvisBG() -> some View {
        background(JarvisTheme.background.ignoresSafeArea())
    }
}
