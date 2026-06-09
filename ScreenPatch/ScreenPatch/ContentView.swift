import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: MaskStore

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
            mainContent
        }
        .frame(width: 320)
        .background(.ultraThinMaterial)
    }

    // MARK: - Header

    var headerBar: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundStyle(.blue)
            Text("ScreenPatch")
                .font(.headline)
            Spacer()
            Toggle("", isOn: $store.overlayEnabled)
                .toggleStyle(.switch)
                .help("显示/隐藏补偿遮罩")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Main

    var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Global opacity
                GroupBox("全局设置") {
                    VStack(alignment: .leading, spacing: 8) {
                        LabeledSlider(
                            label: "整体透明度",
                            value: $store.globalOpacity,
                            range: 0...1,
                            format: { String(format: "%.0f%%", $0 * 100) }
                        )
                    }
                }

                // Edit controls
                GroupBox("编辑模式") {
                    VStack(alignment: .leading, spacing: 8) {
                        if store.isEditing {
                            Text("点击屏幕任意位置添加控制点")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("已添加 \(store.draftPoints.count) 个点（至少需要 3 个）")
                                .font(.caption)
                                .foregroundStyle(store.draftPoints.count >= 3 ? .green : .orange)

                            HStack {
                                Button("确认多边形") {
                                    store.commitDraft()
                                    store.isEditing = false
                                }
                                .disabled(store.draftPoints.count < 3)
                                .buttonStyle(.borderedProminent)

                                Button("取消") {
                                    store.cancelDraft()
                                    store.isEditing = false
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            Button {
                                store.isEditing = true
                            } label: {
                                Label("新建遮罩区域", systemImage: "plus.circle")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Regions list
                if !store.regions.isEmpty {
                    GroupBox("已保存区域") {
                        VStack(spacing: 0) {
                            ForEach($store.regions) { $region in
                                RegionRow(region: $region) {
                                    store.deleteRegion(region.id)
                                }
                                Divider()
                            }
                        }
                    }
                }

                // Quick test button
                GroupBox("快速测试") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("在左下角生成一个示例亮斑补偿区域")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("生成示例遮罩") {
                            addExampleRegion()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(12)
        }
    }

    private func addExampleRegion() {
        // Bottom-left irregular patch (normalized coords, y=0 is top)
        let example = PatchRegion(
            points: [
                CGPoint(x: 0.0,  y: 0.72),
                CGPoint(x: 0.05, y: 0.68),
                CGPoint(x: 0.12, y: 0.70),
                CGPoint(x: 0.15, y: 0.76),
                CGPoint(x: 0.10, y: 0.82),
                CGPoint(x: 0.03, y: 0.85),
                CGPoint(x: 0.0,  y: 0.80),
            ],
            opacity: 0.4,
            feather: 24
        )
        store.regions.append(example)
    }
}

// MARK: - Region Row

struct RegionRow: View {
    @Binding var region: PatchRegion
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(region.points.count) 个控制点")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }

            LabeledSlider(
                label: "暗度",
                value: $region.opacity,
                range: 0...1,
                format: { String(format: "%.0f%%", $0 * 100) }
            )

            LabeledSlider(
                label: "羽化",
                value: $region.feather,
                range: 0...80,
                format: { String(format: "%.0fpt", $0) }
            )
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Helpers

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: (Double) -> String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(width: 56, alignment: .leading)
            Slider(value: $value, in: range)
            Text(format(value))
                .font(.caption)
                .monospacedDigit()
                .frame(width: 44, alignment: .trailing)
        }
    }
}
