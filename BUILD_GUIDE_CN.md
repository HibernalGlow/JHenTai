# JHenTai 编译指南

## 前置要求

### 1. 安装 Flutter SDK
- 下载 Flutter SDK: https://flutter.dev/docs/get-started/install
- 将 Flutter 添加到系统 PATH 环境变量
- 运行 `flutter doctor` 检查环境配置

### 2. 平台特定要求

#### Windows
- Visual Studio 2019 或更高版本（带 C++ 桌面开发组件）
- Windows SDK 10.0 或更高版本

#### macOS
- Xcode 13.0 或更高版本
- CocoaPods

#### Linux
- clang、cmake、ninja-build、pkg-config、gtk3-devel

#### Android
- Android Studio
- Android SDK (API 21 或更高版本)

#### iOS
- macOS 上的 Xcode
- CocoaPods

## 环境配置

### 1. 禁用 Azure China NuGet 源（Windows）

如果遇到 NuGet SSL 证书错误，需要禁用 Azure China 源：

```powershell
dotnet nuget disable source "Azure China"
```

### 2. 获取依赖

```bash
flutter pub get
```

## 编译步骤

### Windows

```bash
flutter build windows --release
```

编译产物位于 `build\windows\x64\runner\Release\jhentai.exe`

### macOS

```bash
flutter build macos --release
```

编译产物位于 `build\macos\Build\Products\Release\jhentai.app`

### Linux

```bash
flutter build linux --release
```

编译产物位于 `build\linux\x64\release\bundle\`

### Android

```bash
flutter build apk --release
```

编译产物位于 `build\app\outputs\flutter-apk\app-release.apk`

### iOS

```bash
flutter build ios --release
```

需要使用 Xcode 打开 `ios/Runner.xcworkspace` 进行最终打包

## 已知问题

### 1. system_network_proxy 插件问题

**问题**: Windows 平台编译时会出现缺少 `system_network_proxy_windows/none.h` 头文件的错误。

**解决方案**: 在编译前运行修复脚本：

```bash
.\fix_build.bat
flutter build windows --release
```

**说明**: 该问题不影响功能。Windows 平台不支持系统代理功能（通过 `system_network_proxy` 插件），但用户仍可手动配置 HTTP/SOCKS 代理。移动端（Android/iOS）的系统代理功能不受影响。

### 2. Material 3 兼容性问题

**问题**: `lib/src/config/theme_config.dart:23` 中 `DialogTheme` 类型不匹配。

**解决方案**: 已在代码中将 `DialogTheme` 改为 `DialogThemeData` 以兼容 Material 3。

### 3. main.dart 位置问题

**问题**: Flutter 默认期望 `lib/main.dart` 作为入口文件，但本项目使用 `lib/src/main.dart`。

**解决方案**: 已创建 `lib/main.dart` 重定向文件，内容为 `export 'src/main.dart';`

## 清理缓存

如果遇到编译问题，可以尝试清理缓存：

```bash
flutter clean
flutter pub get
```

## CI/CD

项目使用 GitHub Actions 进行自动化构建，配置文件位于 `.github/workflows/build_publish.yml`。

CI 配置使用 `-t lib/src/main.dart` 参数指定入口文件。

## 许可证

本项目基于 GPL-3.0 许可证开源。