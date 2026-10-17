import SwiftUI

struct MainShell: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Content area — ABOVE the tab bar (no ZStack overlay)
            Group {
                switch selectedTab {
                case 0: AssistantHomeView()
                case 1: MemoryCenterView()
                case 2: TasksView()
                case 3: IntegrationsView()
                case 4: SettingsView()
                default: AssistantHomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar
            HStack(spacing: 0) {
                tabButton(icon: "waveform", label: "JARVIS",     tag: 0)
                tabButton(icon: "brain.head.profile", label: "Memory",    tag: 1)
                tabButton(icon: "checklist",           label: "Tasks",     tag: 2)
                tabButton(icon: "link.circle",         label: "Services",  tag: 3)
                tabButton(icon: "gearshape",           label: "Settings",  tag: 4)
            }
            .frame(height: 56)
            .background(
                JarvisTheme.surface
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.white.opacity(0.1)),
                        alignment: .top
                    )
            )
            // Respect home indicator safe area
            .padding(.bottom, 0)
            .background(JarvisTheme.surface.ignoresSafeArea(edges: .bottom))
        }
        .background(JarvisTheme.background.ignoresSafeArea())
    }

    @ViewBuilder
    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tag }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: selectedTab == tag ? icon + ".fill" : icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.monochrome)
                Text(label)
                    .font(JarvisTheme.caption())
            }
            .foregroundColor(selectedTab == tag ? JarvisTheme.accent : JarvisTheme.textTertiary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44) // accessibility min tap target
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
