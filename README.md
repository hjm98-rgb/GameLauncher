# 游戏启动器（GameLauncher）

一个 SwiftUI 写的 iOS 游戏启动器：负责**下载游戏**和**启动游戏**，游戏本体在虚拟机里跑（Windows / 安卓），设置里可调内存分配。

- 下载到 `App/Documents/Downloads/`，显示进度。
- 启动用 URL Scheme 打开对应 App 或 UTM 虚拟机配置。
- 自动检测 JIT：没开 JIT 时启动按钮旁会提示，点“启动游戏”先弹“有可能会卡顿，还要继续游玩吗？”，点「继续」才进游戏，点「不要」不启动。

## 目录结构

```
GameLauncher/
├── project.yml                      # XcodeGen 工程定义
├── GameLauncher/
│   ├── GameLauncherApp.swift        # App 入口
│   ├── GameLauncher.entitlements    # JIT 权限（allow-jit）
│   ├── Models/Game.swift            # 游戏模型（独立App / Windows / 安卓 虚拟机）
│   ├── Services/
│   │   ├── GameLibrary.swift        # 游戏库持久化
│   │   ├── GameDownloader.swift     # 下载管理器
│   │   └── Launcher.swift           # JIT 检测 + 启动
│   └── Views/
│       ├── ContentView.swift        # 底部 Tab
│       ├── GameGridView.swift       # 游戏网格首页
│       ├── GameDetailView.swift     # 详情 + 下载 + 启动 + JIT 提示
│       ├── AddGameView.swift        # 手动添加游戏
│       └── SettingsView.swift       # 内存分配 / JIT 状态 / 目录导入
└── .github/workflows/build.yml      # GitHub Actions 出无签名 IPA
```

## 打包成应用（出无签名 IPA）

1. 把 `GameLauncher` 文件夹整个推到你的 GitHub 仓库。
2. Actions → 手动运行 `Build unsigned IPA`（push 也会自动跑）。
3. 下载产物 `GameLauncher-unsigned-ipa`。
4. 把 IPA 传到 iPad（隔空投送/文件），用 **TrollStore** 打开安装 —— TrollStore 会自动注入 JIT 权限。

> 本项目不校验签名，是「无签名 IPA」，由 TrollStore 在设备端签名。别用 Xcode 直接跑真机，会因无签名失败。

## 添加游戏

首页右上角 **+**：

- **独立 App**：填“启动链接”为该 App 的 URL Scheme（如 `appname://`）。
- **虚拟机游戏**：选 **Windows** 或 **安卓**，填 UTM 虚拟机配置的启动链接（UTM 支持 Windows/安卓），比如 `utms://open?name=你的虚拟机名`（以你用的 UTM 版本实际 scheme 为准）。
- 下载链接填游戏文件地址，存进启动器自己的 Downloads。

## 下载与虚拟机的衔接

- 启动器把文件下到它自己的沙盒 `Documents/Downloads/`。
- 虚拟机磁盘镜像若要给 UTM 用：文件 → 分享 → 存储到“文件”，再在 UTM 里导入对应磁盘。
- 实际游戏运行动态（内存、磁盘）由 UTM 虚拟机配置决定；设置里的“默认分配”只作偏好记录。

## Steam 游戏（你有授权的）

Steam 游戏的授权绑定在你的 **Steam 账号**上，Windows 虚拟机里登录你自己的号即可玩。用一个专门的、自己的 Steam 账号，别用共享号（共享号不能异地长期用，还容易被封）。创建免费，邮箱注册，登录要 Steam 令牌。Family Sharing 是给别人共享你库里的游戏，不是让你用别人的号。

## JIT 说明

- TrollStore 安装会自动注入 `com.apple.security.cs.allow-jit`，App 通过读这个 entitlement 判断 JIT 是否可用。
- 没开 JIT：虚拟机只能慢速解释执行，会卡；启动前弹确认框，让你选择继续还是取消。
