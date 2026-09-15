import SwiftUI

@main
struct DriveDashApp: App {
    @StateObject private var pipManager = PiPManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pipManager)
        }
    }
}
