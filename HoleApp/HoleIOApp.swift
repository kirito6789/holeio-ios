import SwiftUI

@main
struct HoleIOApp: App {
    var body: some Scene {
        WindowGroup {
            HoleGameView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}
