import UIKit
import Darwin

/// JIT 权限检测（运行时探针）。
/// 尝试映射一块可读可写可执行的内存页：JIT 开启（有 allow-jit 权限）时成功，
/// 否则返回失败。TrollStore 安装的应用会注入 JIT 权限，因此可正常探测。
final class JITChecker {
    static var isAvailable: Bool {
        let page = mmap(nil, 4096,
                        PROT_READ | PROT_WRITE | PROT_EXEC,
                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)
        if page != MAP_FAILED {
            munmap(page, 4096)
            return true
        }
        return false
    }
}

/// 启动游戏：用 URL Scheme 打开对应 App / UTM 虚拟机配置。
enum Launcher {
    static func open(_ game: Game) {
        guard let url = game.launchTarget else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
