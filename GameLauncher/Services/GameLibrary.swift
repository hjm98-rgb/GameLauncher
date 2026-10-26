import Foundation
import Combine

final class GameLibrary: ObservableObject {
    @Published var games: [Game] = []

    private let key = "games"

    init() {
        load()
        // 首次运行时给两个示例，方便测试界面
        if games.isEmpty {
            games = [
                Game(name: "示例游戏", icon: "🎮", kind: .app, launchURL: "yourappscheme://"),
                Game(name: "Windows 虚拟机游戏", icon: "🪟", kind: .vm, vmOS: .windows, launchURL: "utms://open?name=MyWindows"),
                Game(name: "安卓虚拟机游戏", icon: "🤖", kind: .vm, vmOS: .android, launchURL: "utms://open?name=MyAndroid")
            ]
            save()
        }
    }

    func add(_ game: Game) { games.append(game); save() }

    func update(_ game: Game) {
        if let i = games.firstIndex(where: { $0.id == game.id }) {
            games[i] = game
            save()
        }
    }

    func remove(_ game: Game) { games.removeAll { $0.id == game.id }; save() }

    func markDownloaded(_ id: UUID, fileName: String?) {
        if let i = games.firstIndex(where: { $0.id == id }) {
            games[i].isDownloaded = true
            games[i].localFileName = fileName
            save()
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Game].self, from: data) else { return }
        games = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(games) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
