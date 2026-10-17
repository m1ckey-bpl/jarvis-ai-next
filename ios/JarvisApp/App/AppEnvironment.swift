import Foundation
import SwiftUI

/// Root environment object — owns and wires all service singletons.
@MainActor
final class AppEnvironment: ObservableObject {

    // MARK: - Services

    let catalog      = ProviderCatalog.shared
    let speechEngine = SpeechEngine()
    let memoryStore  = MemoryStore()
    let reminders    = ReminderManager()
    let context      = ConversationContext()

    private(set) lazy var orchestrator: AgentOrchestrator = {
        AgentOrchestrator(
            catalog: catalog,
            context: context,
            memory: memoryStore,
            speech: speechEngine
        )
    }()

    // MARK: - Onboarding

    @Published var isOnboarded: Bool

    init() {
        isOnboarded = UserDefaults.standard.bool(forKey: "jarvis.next.isOnboarded")
    }

    func completeOnboarding() {
        isOnboarded = true
        UserDefaults.standard.set(true, forKey: "jarvis.next.isOnboarded")
    }

    func resetOnboarding() {
        isOnboarded = false
        UserDefaults.standard.set(false, forKey: "jarvis.next.isOnboarded")
    }
}
