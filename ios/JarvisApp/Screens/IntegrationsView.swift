import SwiftUI

public struct IntegrationsView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedService: IntegrationService? = nil

    public enum IntegrationService: String, Identifiable, CaseIterable {
        case gmail = "Gmail"
        case github = "GitHub"
        case calendar = "Apple Calendar"
        case appleReminders = "Apple Reminders"
        case whatsapp = "WhatsApp"
        case instagram = "Instagram"

        public var id: String { rawValue }

        public var icon: String {
            switch self {
            case .gmail: return "envelope.fill"
            case .github: return "chevron.left.forwardslash.chevron.right"
            case .calendar: return "calendar"
            case .appleReminders: return "list.bullet"
            case .whatsapp: return "message.fill"
            case .instagram: return "camera.fill"
            }
        }

        public var summary: String {
            switch self {
            case .gmail: return "Read, summarize, and draft email replies with your approval."
            case .github: return "Inspect repositories, track open issues, and trigger workflows."
            case .calendar: return "Check upcoming schedule and draft calendar appointments."
            case .appleReminders: return "Sync with system reminders and lists."
            case .whatsapp: return "Read/send messages (Meta Cloud API / Business Platform)."
            case .instagram: return "Direct message integrations via official Graph API."
            }
        }

        public var isOfficialSupported: Bool {
            switch self {
            case .gmail, .github, .calendar, .appleReminders: return true
            case .whatsapp, .instagram: return false
            }
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    JarvisSectionHeader("CONNECTED SERVICES")

                    ForEach(IntegrationService.allCases) { service in
                        serviceRow(service: service)
                    }
                }
                .padding(.horizontal, JarvisTheme.m)
                .padding(.bottom, JarvisTheme.l)
            }
            .navigationTitle("Services & Integrations")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedService) { service in
                serviceDetailSheet(service: service)
            }
            .jarvisBG()
        }
    }

    @ViewBuilder
    private func serviceRow(service: IntegrationService) -> some View {
        Button {
            selectedService = service
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: JarvisTheme.radiusM, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Image(systemName: service.icon)
                        .font(.system(size: 20))
                        .foregroundColor(JarvisTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(service.rawValue)
                            .font(JarvisTheme.headline())
                            .foregroundColor(JarvisTheme.textPrimary)
                        Spacer()
                        if service.isOfficialSupported {
                            JarvisStatusBadge(text: "Available", color: JarvisTheme.accent)
                        } else {
                            JarvisStatusBadge(text: "Requires OAuth", color: JarvisTheme.textTertiary)
                        }
                    }
                    Text(service.summary)
                        .font(JarvisTheme.caption())
                        .foregroundColor(JarvisTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            .padding(JarvisTheme.m)
            .glassCard(cornerRadius: JarvisTheme.radiusM)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func serviceDetailSheet(service: IntegrationService) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(JarvisTheme.accent.opacity(0.15))
                        .frame(width: 80, height: 80)
                    Image(systemName: service.icon)
                        .font(.system(size: 36))
                        .foregroundColor(JarvisTheme.accent)
                }
                .padding(.top, JarvisTheme.l)

                VStack(spacing: 6) {
                    Text(service.rawValue)
                        .font(JarvisTheme.title2())
                        .foregroundColor(JarvisTheme.textPrimary)
                    Text(service.summary)
                        .font(JarvisTheme.body())
                        .foregroundColor(JarvisTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, JarvisTheme.l)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("AUTHORIZATION POLICY")
                        .font(JarvisTheme.caption())
                        .foregroundColor(JarvisTheme.textTertiary)
                    Text("JARVIS strictly uses official APIs and requires explicit user confirmation before sending any emails, writing messages, or performing state mutations.")
                        .font(JarvisTheme.callout())
                        .foregroundColor(JarvisTheme.textSecondary)
                }
                .padding(JarvisTheme.m)
                .glassCard(cornerRadius: JarvisTheme.radiusM)
                .padding(.horizontal, JarvisTheme.m)

                Spacer()

                JarvisButton(title: "Done") {
                    selectedService = nil
                }
                .padding(.horizontal, JarvisTheme.m)
                .padding(.bottom, JarvisTheme.l)
            }
            .navigationTitle(service.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .jarvisBG()
        }
    }
}
