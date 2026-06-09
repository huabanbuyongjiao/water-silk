import SwiftUI
import Combine

/// A single polygon patch region
struct PatchRegion: Identifiable, Codable {
    var id: UUID = UUID()
    var points: [CGPoint]       // normalized 0…1 coords relative to screen
    var opacity: Double = 0.4   // overlay darkness
    var feather: Double = 20.0  // feather radius in points

    var isComplete: Bool { points.count >= 3 }
}

/// Global state shared between the control panel and the overlay
class MaskStore: ObservableObject {
    static let shared = MaskStore()

    @Published var regions: [PatchRegion] = []
    @Published var selectedRegionID: UUID? = nil

    // Editing state
    @Published var isEditing: Bool = false
    @Published var draftPoints: [CGPoint] = []  // current polygon being drawn

    // Global overlay visibility
    @Published var overlayEnabled: Bool = true
    @Published var globalOpacity: Double = 1.0

    private let saveURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("ScreenPatch", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("regions.json")
    }()

    init() {
        load()
    }

    func addDraftPoint(_ point: CGPoint) {
        draftPoints.append(point)
    }

    func commitDraft() {
        guard draftPoints.count >= 3 else { return }
        let region = PatchRegion(points: draftPoints)
        regions.append(region)
        draftPoints = []
        save()
    }

    func cancelDraft() {
        draftPoints = []
    }

    func deleteRegion(_ id: UUID) {
        regions.removeAll { $0.id == id }
        if selectedRegionID == id { selectedRegionID = nil }
        save()
    }

    func updateRegion(_ region: PatchRegion) {
        if let idx = regions.firstIndex(where: { $0.id == region.id }) {
            regions[idx] = region
            save()
        }
    }

    func movePoint(regionID: UUID, pointIndex: Int, to point: CGPoint) {
        guard let idx = regions.firstIndex(where: { $0.id == regionID }) else { return }
        guard pointIndex < regions[idx].points.count else { return }
        regions[idx].points[pointIndex] = point
        save()
    }

    func deletePoint(regionID: UUID, pointIndex: Int) {
        guard let idx = regions.firstIndex(where: { $0.id == regionID }) else { return }
        guard regions[idx].points.count > 3 else { return }
        regions[idx].points.remove(at: pointIndex)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(regions) else { return }
        try? data.write(to: saveURL)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([PatchRegion].self, from: data) else { return }
        regions = decoded
    }
}

extension CGPoint: Codable {
    public init(from decoder: Decoder) throws {
        var c = try decoder.unkeyedContainer()
        let x = try c.decode(CGFloat.self)
        let y = try c.decode(CGFloat.self)
        self.init(x: x, y: y)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.unkeyedContainer()
        try c.encode(x)
        try c.encode(y)
    }
}
