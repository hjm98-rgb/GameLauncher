import UIKit
import Security

/// JIT 权限检测。
/// TrollStore 安装的应用会被注入 `com.apple.security.cs.allow-jit` 权限，
/// 所以通过读取该 entitlement 来判断 JIT 是否开启。
final class JITChecker {
    static var isAvailable: Bool {
        guard let task = SecTaskCreateFromSelf(nil) else { return false }
        let value = SecTaskCopyValueForEntitlement(
            task, "com.apple.security.cs.allow-jit" as CFString, nil)
        return (value as? Bool) ?? false
    }
}

/// 启动游戏：用 URL Scheme 打开对应 App / UTM 虚拟机配置。
enum Launcher {
    static func open(_ game: Game) {
        guard let url = game.launchTarget else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
