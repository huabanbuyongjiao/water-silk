import SwiftUI
import AppKit

/// The full-screen transparent overlay rendered on top of everything
struct OverlayView: View {
    @EnvironmentObject var store: MaskStore

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Committed regions
                if store.overlayEnabled {
                    ForEach(store.regions) { region in
                        if region.isComplete {
                            PatchRegionShape(points: region.points, size: geo.size)
                                .fill(Color.black.opacity(region.opacity * store.globalOpacity))
                                .blur(radius: region.feather * 0.5)
                        }
                    }
                }

                // Draft polygon being drawn
                if store.isEditing {
                    DraftPolygonView(points: store.draftPoints, size: geo.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                store.isEditing
                    ? SpatialTapGesture()
                        .onEnded { value in
                            let norm = CGPoint(
                                x: value.location.x / geo.size.width,
                                y: value.location.y / geo.size.height
                            )
                            store.addDraftPoint(norm)
                        }
                    : nil
            )
        }
        .ignoresSafeArea()
    }
}

/// Converts normalized points to a SwiftUI Shape
struct PatchRegionShape: Shape {
    let points: [CGPoint]
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        guard points.count >= 2 else { return Path() }
        var path = Path()
        let abs = points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
        path.move(to: abs[0])
        for p in abs.dropFirst() { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}

/// Live preview of the polygon currently being drawn
struct DraftPolygonView: View {
    let points: [CGPoint]
    let size: CGSize

    var absPoints: [CGPoint] {
        points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
    }

    var body: some View {
        ZStack {
            // Fill preview
            if points.count >= 3 {
                PatchRegionShape(points: points, size: size)
                    .fill(Color.black.opacity(0.25))
            }

            // Outline
            if absPoints.count >= 2 {
                Path { path in
                    path.move(to: absPoints[0])
                    for p in absPoints.dropFirst() { path.addLine(to: p) }
                }
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
            }

            // Control points
            ForEach(Array(absPoints.enumerated()), id: \.offset) { _, pt in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                    .position(pt)
            }

            // Closing hint: line from last point to first
            if absPoints.count >= 3 {
                Path { path in
                    path.move(to: absPoints.last!)
                    path.addLine(to: absPoints[0])
                }
                .stroke(Color.yellow.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
        }
    }
}
