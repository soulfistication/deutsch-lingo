import SwiftUI

@main
struct DeutschLingoApp: App {
    @State private var store = ProgressStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(store.prefersDarkMode ? .dark : nil)
        }
    }
}
