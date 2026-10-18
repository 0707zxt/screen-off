# 一键息屏 · Screen Off

点击桌面图标，锁屏息屏。给自己用的极简 Android 小工具。

- 原生 Java，只有一个功能，无第三方运行库。
- APK 约 13 KB，无广告、无网络权限、无统计或数据上传。
- 不需要 Root 或设备管理员；通过系统无障碍服务执行锁屏。
- 不订阅无障碍事件，不读取窗口内容，不申请手势或截图能力。
- Android 9（API 28）及以上，目标版本 Android 15（API 35）。

## 下载和使用

[下载 APK](dist/ScreenOff.apk?raw=true)

1. 将 APK 发送到手机并安装。按系统提示允许此次安装来源。
2. 首次打开“一键息屏”，点击“去开启”。
3. 在系统无障碍设置的“已下载的应用 / 服务”中开启“一键息屏”。
4. 返回桌面，点击应用图标即可息屏。

首次授权只需操作一次。应用不显示常驻通知，也不包含其他功能页面。

### 常见问题

**提示“受限设置”，无法开启服务**：在手机“设置 → 应用 → 一键息屏 → 右上角菜单”查看是否有“允许受限设置”，允许后重试。MIUI / HyperOS 的菜单位置可能随版本变化。

**后台清理后失效**：关闭并重新开启该无障碍服务；如果频繁发生，可在系统应用设置中允许自启动。

**能否指纹解锁**：使用系统 `GLOBAL_ACTION_LOCK_SCREEN` 接口；指纹与人脸解锁的可用性仍取决于系统及其安全策略。

**卸载**：先在无障碍设置中关闭服务，然后正常卸载。

本项目面向 Redmi 12 Turbo 的自用需求，用户反馈可用；未进行广泛的机型、MIUI / HyperOS 版本兼容性测试。

## 从源码构建

无需 Android Studio 或 Gradle。构建脚本面向 Windows，使用 PowerShell 7、JDK 17 或更新版本，以及 [Google 官方 Android SDK](https://developer.android.com/tools)。已使用 JDK 21 编译验证。

安装以下 SDK 组件（需自行阅读并接受 Google 的 SDK 许可条款）：

```text
platforms;android-35
build-tools;35.0.0
```

安装好命令行工具后，可通过 `sdkmanager "platforms;android-35" "build-tools;35.0.0"` 安装组件。将 Java 的 `bin` 目录加入 PATH，在项目目录运行：

```powershell
$env:ANDROID_HOME = 'C:\Android\Sdk'
# 用自己的签名密码替换示例值；不应把密码提交到仓库。
$env:SCREENOFF_STORE_PASSWORD = 'replace-with-your-own-password'
./build.ps1
Remove-Item Env:SCREENOFF_STORE_PASSWORD
```

也可以明确指定工具路径（仍需先设置签名密码）：

```powershell
./build.ps1 -BuildToolsPath 'C:\Android\Sdk\build-tools\35.0.0' -AndroidJar 'C:\Android\Sdk\platforms\android-35\android.jar'
```

输出为 `dist/ScreenOff.apk`，脚本同时验证 APK 签名和 ZIP 对齐。

首次构建会生成本地 `.signing/personal.jks`。请自行安全备份密钥和密码：同包名的覆盖安装更新必须使用相同签名。自己生成的签名无法覆盖安装仓库提供的 APK，需要先卸载旧版本。发布者的签名密钥不随源码分发。

## 源码与隐私

```text
AndroidManifest.xml     应用、入口和无障碍服务声明
src/                    两个 Java 类：授权引导和锁屏服务
res/                    图标与服务描述
build.ps1               编译、对齐、签名和校验
dist/ScreenOff.apk      已签名安装包
```

应用通过 Android 提供的 [无障碍锁屏接口](https://developer.android.com/reference/android/accessibilityservice/AccessibilityService#GLOBAL_ACTION_LOCK_SCREEN) 工作。可在 `res/xml/accessibility.xml` 和源码中检查能力声明与行为。项目没有第三方代码或运行依赖。

## 许可证

采用 [MIT License](LICENSE)。欢迎修改和分发；请保留版权和许可证声明。问题或改进可提交 Issue / Pull Request。
