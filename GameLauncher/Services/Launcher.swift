import UIKit
import Darwin

/// JIT 权限检测（真实检测法）。
/// 原理：JIT 可用时进程处于「已调试（debugged）」状态，对应代码签名标志 CS_DEBUGGED。
/// 通过 csops(CS_OPS_STATUS) 读取本进程的代码签名标志来判断。
/// - 巨魔商店（TrollStore）安装并启用 JIT 时：标志被置位 → 检测为开启
/// - 普通签名工具（未开 JIT）：标志未置位 → 检测为未开启
/// 这是社区里 UTM / 模拟器 / JIT 工具通用的检测方法。
final class JITChecker {
    static var isAvailable: Bool {
        var flags: UInt32 = 0
        let rc = withUnsafeMutableBytes(of: &flags) { ptr in
            csops(getpid(), CS_OPS_STATUS, ptr.baseAddress, MemoryLayout<UInt32>.size)
        }
        return rc == 0 && (flags & CS_DEBUGGED) != 0
    }
}

// ---- csops 相关（libSystem 私有符号，社区标准用法）----
private let CS_OPS_STATUS: UInt32 = 0
private let CS_DEBUGGED: UInt32 = 0x100

@_silgen_name("csops")
private func csops(_ pid: pid_t, _ ops: UInt32,
                   _ useraddr: UnsafeMutableRawPointer?, _ usersize: Int) -> Int

/// 启动游戏：用 URL Scheme 打开对应 App / UTM 虚拟机配置。
enum Launcher {
    static func open(_ game: Game) {
        guard let url = game.launchTarget else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
