# ScreenPatch

macOS 应用，用于补偿 MacBook 屏幕液体进屏导致的局部亮斑。

通过在屏幕上叠加半透明黑色多边形遮罩，软件补偿液体亮斑，使视觉亮度尽量均匀。

## 功能

- 永远置顶的透明覆盖窗口（overlay）
- 鼠标点击创建不规则多边形遮罩区域
- 每个区域独立控制暗度（0~100%）和羽化（feather）
- 全局透明度控制
- 自动保存和加载区域配置

## 快速开始

### 要求

- macOS 13.0+
- Xcode 15+

### 运行

```bash
cd ScreenPatch
open ScreenPatch.xcodeproj
```

在 Xcode 中按 `Cmd+R` 编译运行。

### 使用步骤

1. 启动后，右上角菜单栏出现应用图标，弹出控制面板
2. 点击「生成示例遮罩」先看效果——屏幕左下角会出现半透明黑色区域
3. 点击「新建遮罩区域」进入编辑模式
4. 在屏幕上点击添加控制点（至少 3 个）
5. 点击「确认多边形」完成一个区域
6. 通过滑块调整每个区域的暗度和羽化程度

### 注意

- App Sandbox 设为关闭（`false`），这样 overlay 窗口才能覆盖其他应用
- 首次运行 macOS 可能提示安全警告，在系统设置 → 安全性中允许即可
- 编辑模式下鼠标点击被 overlay 捕获，退出编辑后恢复正常鼠标穿透

## 文件结构

```
ScreenPatch/
├── ScreenPatch.xcodeproj/
│   └── project.pbxproj
└── ScreenPatch/
    ├── ScreenPatchApp.swift          # 入口，AppDelegate，创建 overlay 窗口
    ├── MaskStore.swift               # 全局状态（区域列表、编辑状态）
    ├── OverlayWindowController.swift # 全屏透明置顶窗口
    ├── OverlayView.swift             # 渲染多边形遮罩 + 编辑时的绘制预览
    ├── ContentView.swift             # 控制面板 UI
    └── ScreenPatch.entitlements      # 关闭沙盒
```

## 下一步计划

- [ ] 照片导入 + 自动亮斑检测（Vision Framework）
- [ ] 透视矫正（屏幕四角检测）
- [ ] 自动生成渐变 Mask
- [ ] 拖动已有控制点进行微调
- [ ] 开机自启动
