import SwiftUI

struct SettingsView: View {
    @AppStorage("vmMemoryMB") private var vmMemory = 2048
    @AppStorage("catalogURL") private var catalogURL = ""
    @EnvironmentObject var library: GameLibrary
    @State private var importMessage = ""

    private var jitOn: Bool { JITChecker.isAvailable }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("虚拟机内存分配")) {
                    Stepper(value: $vmMemory, in: 512...8192, step: 256) {
                        Text("默认分配：\(vmMemory) MB")
                    }
                    Text("实际内存由 UTM 虚拟机配置控制，此处仅记录你的偏好。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("JIT 状态")) {
                    HStack {
                        Image(systemName: jitOn ? "bolt.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(jitOn ? .green : .orange)
                        Text(jitOn ? "JIT 已开启" : "JIT 未开启")
                            .foregroundColor(jitOn ? .green : .orange)
                    }
                    Text("TrollStore 安装会自动注入 JIT 权限；若未开启，启动游戏前会提示可能卡顿。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("游戏目录导入")) {
                    TextField("JSON 目录链接", text: $catalogURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    Button("导入目录") { importCatalog() }
                    if !importMessage.isEmpty {
                        Text(importMessage).font(.caption).foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }

    private func importCatalog() {
        guard let url = URL(string: catalogURL) else {
            importMessage = "链接无效"
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { importMessage = "导入失败" }
                return
            }
            guard let games = try? JSONDecoder().decode([Game].self, from: data) else {
                DispatchQueue.main.async { importMessage = "JSON 格式不对" }
                return
            }
            DispatchQueue.main.async {
                for g in games { library.add(g) }
                importMessage = "已导入 \(games.count) 个游戏"
            }
        }.resume()
    }
}
