import SwiftUI

@main
struct GameLauncherApp: App {
    @StateObject private var library = GameLibrary()
    @StateObject private var downloader = GameDownloader()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environmentObject(downloader)
        }
    }
}
