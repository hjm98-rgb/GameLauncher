import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GameGridView()
                .tabItem { Label("游戏", systemImage: "gamecontroller.fill") }
            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
        }
    }
}
