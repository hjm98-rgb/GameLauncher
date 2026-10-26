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
    var versions: [GameVersion] = []

    var launchTarget: URL? {
        guard let s = launchURL, let u = URL(string: s) else { return nil }
        return u
    }
}

/// 一个可下载的游戏版本（比如 Minecraft 国际版 1.21.4 / 1.20.6）
/// platform 对应 MCDL 网站的分区：安卓 / 苹果
struct GameVersion: Identifiable, Codable {
    var id = UUID()
    var version: String
    var url: String
    var platform: GamePlatform = .ios
    var isDownloaded: Bool = false
    var localFileName: String? = nil
}

enum GamePlatform: String, Codable, CaseIterable, Identifiable {
    case ios = "苹果"
    case android = "安卓"
    var id: String { rawValue }
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
