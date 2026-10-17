import SwiftUI

public struct WaveformView: View {
    public var intensity: Double
    public var isActive: Bool

    @State private var phase: Double = 0

    public init(intensity: Double, isActive: Bool) {
        self.intensity = intensity
        self.isActive = isActive
    }

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<24, id: \.self) { i in
                let normalizedI = Double(i) / 24.0
                let sinVal = sin(phase + normalizedI * .pi * 2)
                let baseHeight: CGFloat = isActive ? 8 : 3
                let dynamicHeight: CGFloat = isActive ? CGFloat(abs(sinVal) * intensity * 28 + baseHeight) : baseHeight

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        LinearGradient(
                            colors: [
                                JarvisTheme.accent,
                                JarvisTheme.accentDim
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: max(3, dynamicHeight))
                    .opacity(isActive ? 0.9 : 0.3)
                    .animation(.easeOut(duration: 0.1), value: intensity)
            }
        }
        .frame(height: 36)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}
