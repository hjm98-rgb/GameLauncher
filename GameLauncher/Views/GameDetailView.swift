import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject var library: GameLibrary
    @EnvironmentObject var downloader: GameDownloader
    let gameID: UUID

    @State private var showJITWarning = false

    private var current: Game {
        library.games.first { $0.id == gameID } ?? Game(name: "未知")
    }

    private var jitOn: Bool {
        JITChecker.isAvailable
    }

    var body: some View {
        Form {
            Section("信息") {
                HStack { Text("名称"); Spacer(); Text(current.name).foregroundColor(.secondary) }
                HStack { Text("类型"); Spacer(); Text(current.kind.rawValue).foregroundColor(.secondary) }
                if current.kind == .vm, let os = current.vmOS {
                    HStack { Text("虚拟机"); Spacer(); Text(os.rawValue).foregroundColor(.secondary) }
                }
                if let u = current.sourceURL {
                    HStack { Text("下载"); Spacer(); Text(u).font(.footnote).foregroundColor(.secondary).lineLimit(1) }
                }
                if let u = current.launchURL {
                    HStack { Text("启动"); Spacer(); Text(u).font(.footnote).foregroundColor(.secondary).lineLimit(1) }
                }
            }

            Section("状态") {
                if downloader.isDownloading {
                    ProgressView(value: downloader.progress)
                    Text("下载中…").font(.caption).foregroundColor(.secondary)
                } else if current.isDownloaded {
                    Text("已下载").foregroundColor(.green)
                } else {
                    Text("未下载").foregroundColor(.secondary)
                }
                if let err = downloader.lastError {
                    Text(err).font(.caption).foregroundColor(.red)
                }
            }

            Section {
                if !current.isDownloaded, let u = current.sourceURL {
                    Button("下载游戏") { startDownload(u) }
                        .disabled(downloader.isDownloading)
                }
                if current.isDownloaded || current.launchTarget != nil {
                    Button(action: onLaunchTap) {
                        Label("启动游戏", systemImage: "play.fill")
                    }
                }
            } footer: {
                HStack(spacing: 6) {
                    Image(systemName: jitOn ? "bolt.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(jitOn ? .green : .orange)
                    Text(jitOn ? "JIT 已开启，虚拟机流畅运行" : "JIT 未开启，虚拟机可能卡顿")
                        .font(.caption)
                        .foregroundColor(jitOn ? .green : .orange)
                }
            }
        }
        .navigationTitle(current.name)
        .alert("有可能会卡顿，还要继续游玩吗？", isPresented: $showJITWarning) {
            Button("继续", role: .destructive) {
                Launcher.open(current)
            }
            Button("不要", role: .cancel) {}
        } message: {
            Text("当前未开启 JIT，进入游戏后可能出现明显卡顿。")
        }
    }

    private func startDownload(_ u: String) {
        let fileName = URL(string: u)?.lastPathComponent ?? "\(current.name).bin"
        downloader.download(from: u, fileName: fileName) { result in
            if case .success = result {
                library.markDownloaded(current.id, fileName: fileName)
            }
        }
    }

    private func onLaunchTap() {
        // 需要 JIT 的游戏没开 JIT 时，先弹卡顿确认；开了就直接进
        if jitOn {
            Launcher.open(current)
        } else {
            showJITWarning = true
        }
    }
}
