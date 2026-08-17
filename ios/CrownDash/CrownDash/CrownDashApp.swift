import SwiftUI

@main
struct CrownDashApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    GameCenterManager.shared.authenticate()
                }
        }
    }
}
