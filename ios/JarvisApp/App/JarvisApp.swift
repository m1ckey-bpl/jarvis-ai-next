import SwiftUI

@main
struct JarvisApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
                .preferredColorScheme(.dark)
        }
    }
}
