# English Reader 📚

一个跨平台的英语阅读器应用，支持 Windows、Android、Mac 和 iOS 平台。

## 功能特性 ✨

- 📖 **本地文本阅读**: 支持读取本地 TXT 格式文件
- 📄 **智能分页**: 自动将长文本分割为易读的页面
- 🔍 **字体调整**: 支持动态调整字体大小 (12px - 32px)
- 👆 **手势翻页**: 点击屏幕左侧/右侧进行上一页/下一页
- 🌍 **在线翻译**: 点击任意英文单词获取中文翻译
- 📚 **双语支持**: 本地词典 + 在线翻译API（MyMemory）
- ⚡ **智能缓存**: 自动缓存翻译结果，提升用户体验
- 📱 **跨平台**: 支持 Android、iOS、Windows、macOS 和 Web

## 界面预览 🎨

### 主页面
- 简洁的欢迎界面
- 一键选择文本文件
- 显示已选择文件的信息

### 阅读界面
- 清晰的文本显示
- 页面计数器显示当前页码
- 字体大小调节按钮
- 左右滑动翻页
- 所有英文单词都可点击（蓝色下划线标识）
- 翻译信息以抽屉形式滑出
- 显示翻译来源（词典/在线翻译）
- 智能加载动画

## 技术栈 🛠️

- **框架**: Flutter 3.8+
- **主要依赖**:
  - `file_picker`: 文件选择
  - `http`: 网络请求（在线翻译）
  - `cupertino_icons`: iOS 风格图标

## 项目结构 📁

```
lib/
├── main.dart                          # 应用入口和主页面
├── models/                            # 数据模型
│   └── word_entry.dart                # 单词条目模型
├── views/                             # 视图层
│   ├── reader_screen.dart             # 阅读器界面
│   └── components/                    # 可复用组件
│       ├── interactive_text.dart      # 可点击文本渲染器
│       └── translation_drawer.dart    # 抽屉式翻译信息栏
└── services/                          # 业务逻辑层
    ├── text_pagination.dart           # 文本分页逻辑
    ├── translation_service.dart       # 在线翻译服务（MyMemory API）
    └── word_dictionary.dart           # 本地词典数据
```

## 快速开始 🚀

### 环境要求
- Flutter SDK 3.8 或更高版本
- Dart SDK 3.0 或更高版本

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd english_reader
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 运行到 Android 设备/模拟器
   flutter run

   # 运行到 iOS 设备/模拟器（需要 macOS）
   flutter run -d ios

   # 运行到 Windows
   flutter run -d windows

   # 运行到 macOS（需要 macOS）
   flutter run -d macos

   # 运行到 Web 浏览器
   flutter run -d chrome
   ```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (需要 macOS)
flutter build ios --release

# Windows
flutter build windows --release

# macOS (需要 macOS)
flutter build macos --release

# Web
flutter build web --release
```

## 使用说明 📖

1. **选择文件**
   - 点击主页面的"选择文本文件"按钮
   - 从设备中选择一个 TXT 文件
   - 文件选择后会自动跳转到阅读界面

2. **阅读操作**
   - **翻页**: 点击屏幕左侧（上一页）或右侧（下一页）
   - **字体大小**: 使用顶部工具栏的 +/- 按钮调整
   - **查看页码**: 底部导航栏显示当前页码和总页数
   - **翻译单词**: 点击任意蓝色下划线的英文单词查看翻译
   - **翻译来源**:
     - 💙 本地词典：常用词汇（200+ 单词）
     - 💚 在线翻译：MyMemory API（所有英文单词）
   - **缓存机制**: 翻译结果自动缓存，下次点击秒响应
   - **返回**: 使用系统返回键或点击返回按钮

3. **支持的文本格式**
   - 纯文本文件 (.txt)
   - 编码格式: UTF-8
   - 建议: 较大的文件阅读体验更佳
   - 特色: 所有英文单词支持点击翻译，无需词典预装

## 测试文件 📝

项目根目录提供了一个测试文件 `test.txt`，包含《福尔摩斯探案集》的章节内容，用于测试阅读功能。

## 开发计划 📋

- [ ] 支持更多文本格式（PDF、EPUB）
- [ ] 添加书签功能
- [ ] 支持夜间模式
- [ ] 添加阅读进度保存
- [ ] 支持多语言界面
- [ ] 添加阅读统计
- [ ] 离线词典支持
- [ ] 语音朗读功能
- [ ] 单词本/生词本功能
- [ ] 翻译历史记录
- [ ] 多翻译引擎支持（Google、百度等）

## 常见问题 ❓

**Q: 为什么无法选择文件？**
A: 确保已授予应用文件访问权限。在 Android 6.0+ 设备上，可能需要在设置中手动开启。

**Q: 字体太小/太大怎么办？**
A: 使用阅读界面顶部工具栏的 +/- 按钮调整字体大小，范围为 12px-32px。

**Q: 为什么需要网络权限？**
A: 在线翻译功能需要访问 MyMemory 翻译 API。首次翻译后，结果会缓存到本地，下次查看无需网络。

**Q: 翻译不准确怎么办？**
A: MyMemory API 是机器翻译，建议以理解为主。如需更准确翻译，可参考多个来源。

**Q: 支持哪些平台？**
A: 支持 Android、iOS、Windows、macOS 和 Web（Chrome、Edge、Safari）。所有平台均支持在线翻译功能。

## 许可证 📄

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 贡献 🤝

欢迎提交 Issue 和 Pull Request！

## 联系方式 📧

如有问题或建议，请创建 GitHub Issue。

---

⭐ 如果这个项目对你有帮助，请给它一个星标！
