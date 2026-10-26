import SwiftUI

struct AddGameView: View {
    @EnvironmentObject var library: GameLibrary
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var icon = "🎮"
    @State private var kind: GameKind = .app
    @State private var vmOS: VMOS = .windows
    @State private var sourceURL = ""
    @State private var launchURL = ""

    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("游戏名", text: $name)
                    TextField("图标 (emoji)", text: $icon)
                    Picker("类型", selection: $kind) {
                        ForEach(GameKind.allCases) { k in
                            Text(k.rawValue).tag(k)
                        }
                    }
                    if kind == .vm {
                        Picker("虚拟机系统", selection: $vmOS) {
                            ForEach(VMOS.allCases) { os in
                                Text(os.rawValue).tag(os)
                            }
                        }
                    }
                }
                Section("下载链接") {
                    TextField("下载地址", text: $sourceURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                Section(kind == .vm ? "启动 (UTM 虚拟机配置链接)" : "启动 (URL Scheme)") {
                    TextField("启动链接", text: $launchURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("添加游戏")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        library.add(Game(
                            name: name,
                            icon: icon.isEmpty ? "🎮" : icon,
                            kind: kind,
                            vmOS: kind == .vm ? vmOS : nil,
                            sourceURL: sourceURL.isEmpty ? nil : sourceURL,
                            launchURL: launchURL.isEmpty ? nil : launchURL
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
