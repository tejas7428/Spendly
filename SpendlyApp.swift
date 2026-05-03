import SwiftUI

@main
struct SpendlyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .preferredColorScheme(.light)
        }
    }
}
