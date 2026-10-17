import SwiftUI

struct RootView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        Group {
            if env.isOnboarded {
                MainShell()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: env.isOnboarded)
    }
}
