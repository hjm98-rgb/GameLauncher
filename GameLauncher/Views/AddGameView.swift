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

    // 版本编辑器
    @State private var newVersion = ""
    @State private var newPlatform: GamePlatform = .ios
    @State private var newVersionURL = ""
    @State private var versions: [GameVersion] = []

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

                Section("版本（安卓 / 苹果分区）") {
                    TextField("版本号，如 1.21.4", text: $newVersion)
                    Picker("平台分区", selection: $newPlatform) {
                        ForEach(GamePlatform.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    TextField("该版本下载链接", text: $newVersionURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    Button("添加这个版本") {
                        guard !newVersion.isEmpty, !newVersionURL.isEmpty else { return }
                        versions.append(GameVersion(version: newVersion, url: newVersionURL, platform: newPlatform))
                        newVersion = ""
                        newVersionURL = ""
                    }
                    .disabled(newVersion.isEmpty || newVersionURL.isEmpty)
                    ForEach(versions) { ver in
                        HStack {
                            Text("\(ver.version) · \(ver.platform.rawValue)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                versions.removeAll { $0.id == ver.id }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                        }
                    }
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
                            launchURL: launchURL.isEmpty ? nil : launchURL,
                            versions: versions
                        ))
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
