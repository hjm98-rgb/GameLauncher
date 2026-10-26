import Foundation

struct Game: Identifiable, Codable {
    var id = UUID()
    var name: String
    var icon: String = "🎮"
    var kind: GameKind = .app
    var vmOS: VMOS? = nil
    var sourceURL: String? = nil
    var launchURL: String? = nil
    var isDownloaded: Bool = false
    var localFileName: String? = nil

    var launchTarget: URL? {
        guard let s = launchURL, let u = URL(string: s) else { return nil }
        return u
    }
}

enum GameKind: String, Codable, CaseIterable, Identifiable {
    case app = "独立App"
    case vm = "虚拟机游戏"
    var id: String { rawValue }
}

enum VMOS: String, Codable, CaseIterable, Identifiable {
    case windows = "Windows"
    case android = "安卓"
    var id: String { rawValue }
}
