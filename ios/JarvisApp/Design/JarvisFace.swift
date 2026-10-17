import SwiftUI

public enum AvatarFaceState: Equatable {
    case idle
    case listening
    case thinking
    case speaking
    case executing
    case error
}

public struct JarvisFace: View {
    public var state: AvatarFaceState
    public var jawOpen: Double // 0.0 to 1.0

    @State private var scanOffset: CGFloat = -80
    @State private var idlePulse: CGFloat = 1.0
    @State private var blink: Bool = false

    public init(state: AvatarFaceState, jawOpen: Double = 0.0) {
        self.state = state
        self.jawOpen = jawOpen
    }

    private var auraColor: Color {
        switch state {
        case .idle: return JarvisTheme.accent.opacity(0.35)
        case .listening: return Color(red: 0.1, green: 0.8, blue: 1.0)
        case .thinking: return JarvisTheme.thinking
        case .speaking: return JarvisTheme.success
        case .executing: return Color(red: 0.7, green: 0.4, blue: 1.0)
        case .error: return JarvisTheme.destructive
        }
    }

    public var body: some View {
        ZStack {
            // Ambient outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [auraColor.opacity(0.4), auraColor.opacity(0.0)],
                        center: .center,
                        startRadius: 40,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .scaleEffect(state == .speaking ? 1.0 + CGFloat(jawOpen * 0.12) : idlePulse)

            // Outer metallic rim
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.05), auraColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 210, height: 210)

            // Inner dark cranium surface
            Circle()
                .fill(
                    RadialGradient(
                        colors: [JarvisTheme.surfaceElevated, JarvisTheme.background],
                        center: .center,
                        startRadius: 20,
                        endRadius: 105
                    )
                )
                .frame(width: 204, height: 204)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            // Central faceplate visor
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.9), JarvisTheme.surface.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 160)
                .overlay(
                    RoundedRectangle(cornerRadius: 38, style: .continuous)
                        .stroke(auraColor.opacity(0.4), lineWidth: 1)
                )

            // Thinking scanline effect
            if state == .thinking {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, auraColor.opacity(0.8), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 130, height: 6)
                    .offset(y: scanOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: true)) {
                            scanOffset = 70
                        }
                    }
            }

            VStack(spacing: 22) {
                // Optics (Eyes)
                HStack(spacing: 34) {
                    opticEye(isLeft: true)
                    opticEye(isLeft: false)
                }

                // Digital Nose Bridge Marker
                Capsule()
                    .fill(auraColor.opacity(0.4))
                    .frame(width: 3, height: 14)

                // Dynamic Audio-reactive Mouth
                mouthView
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                idlePulse = 1.05
            }
            startBlinkTimer()
        }
    }

    @ViewBuilder
    private func opticEye(isLeft: Bool) -> some View {
        ZStack {
            // Glow
            Ellipse()
                .fill(auraColor.opacity(0.6))
                .frame(width: 24, height: blink ? 2 : 14)
                .blur(radius: 4)

            // Core optic
            Ellipse()
                .fill(Color.white)
                .frame(width: 18, height: blink ? 1.5 : 9)
                .overlay(
                    Ellipse()
                        .stroke(auraColor, lineWidth: 1)
                )
        }
        .animation(.easeInOut(duration: 0.1), value: blink)
    }

    private var mouthView: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                let factor: Double = {
                    switch index {
                    case 0, 6: return 0.35
                    case 1, 5: return 0.65
                    case 2, 4: return 0.85
                    case 3:    return 1.0
                    default:   return 0.5
                    }
                }()
                let barHeight = max(4.0, (14.0 * factor) + (jawOpen * 26.0 * factor))

                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, auraColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: barHeight)
                    .animation(.easeOut(duration: 0.08), value: jawOpen)
            }
        }
        .frame(height: 38)
    }

    private func startBlinkTimer() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            if state == .idle {
                blink = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    blink = false
                }
            }
        }
    }
}
