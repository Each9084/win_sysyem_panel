# WinSystemPanel: 定时电源控制台



**WinSystemPanel** 是一款基于 Flutter 开发的 Windows 桌面应用，旨在提供一个**简约、高效且具有科幻动感视觉风格**的定时电源管理工具。告别系统原生丑陋的弹窗，用未来感的控制台轻松掌控您的关机、重启和休眠计划。

------



## ✨ 核心特性



- **⚡️ 科幻动感设计：** 采用深色主题与霓虹强调色，提供无边框、高可视度的现代化 UI/UX。
- **⏰ 灵活定时调度：** 支持定时关机、定时重启、定时休眠（Hibernate/Sleep）及随时取消任务。
- **🌐 多语言支持：** 内置国际化（i18n）支持，代码结构已完全分离文本，易于扩展。
- **💻 跨平台架构：** 基于 Flutter 核心架构设计，未来可轻松扩展到 macOS 或 Linux 平台。
- **🛠️ 易于扩展：** 采用 Feature-first 和 Layered Architecture（领域驱动设计），下一阶段可无缝集成设备信息监控（如 CPU 温度、网络活动等）。

------



## 📸 界面预览 (Mockup/Preview)







## ⚙️ 如何安装与使用



### 1. 下载安装包



访问 [Releases 页面](https://www.google.com/search?q=https://github.com/your-username/win_system_panel/releases) 下载最新的 **`WinSystemPanel.exe`** 安装包。



### 2. 快速使用



1. **选择操作：** 在底部的控制区选择 `Shutdown`（关机）、`Restart`（重启）或 `Hibernate`（休眠）。
2. **设置延迟：** 通过滑块或预设按钮选择延迟时间。
3. **启动任务：** 点击主要的霓虹色 **`启动定时`** 按钮。
4. **实时监控：** 界面将切换为实时倒计时，您可以随时点击 **`取消任务`** 按钮来终止操作。

------



## 🚀 项目结构（专业分层）



本项目严格遵循 **Feature-first** 和 **Layered Architecture**（Riverpod State Management），确保了项目的可维护性和可测试性。

```
lib/
├── core/             // 核心基础设施 (主题, 配置, 全局常量)
├── features/         // 业务模块 (关注点分离)
│   ├── power_control/ // 核心定时控制模块
│   │   ├── domain/    // 纯业务模型 (PowerTask)
│   │   ├── application/ // 状态管理与业务逻辑 (PowerController)
│   │   └── presentation/ // 视图层 (Widgets, UI)
│   └── device_info/  // (下一阶段预留)
├── i18n/             // 国际化/多语言文件 (ARB)
└── main.dart         // 应用入口
```

------



## 🛠️ 本地开发环境搭建



如果您想参与贡献或自定义功能：



### 前提条件



1. Flutter SDK (>= 3.x)
2. Windows 桌面开发环境（Visual Studio 2022）
3. Dart 语言基础



### 步骤



1. **克隆仓库：**

   Bash

   ```
   git clone https://github.com/your-username/win_system_panel.git
   cd win_system_panel
   ```

2. **获取依赖：**

   Bash

   ```
   flutter pub get
   ```

3. **生成多语言代码：**

   Bash

   ```
   flutter gen-l10n
   ```

4. **运行应用：**

   Bash

   ```
   flutter run -d windows
   ```

------



## 🤝 贡献与支持



欢迎对本项目提出任何建议、问题或 Pull Requests！

- 如果您发现 Bug，请在 [Issues] 提交。
- 如果您希望添加新的翻译，请修改 `lib/i18n/l10n/` 目录下的 ARB 文件。

------



## 📄 许可证



本项目基于 MIT 许可证发布。详见 [LICENSE](https://www.google.com/search?q=LICENSE) 文件。

------

<p align="center"> <i>Built with ❤️ using Flutter and Dart.</i> </p>
