import SwiftUI

enum HotspotNormalization {
    static func normalize(point: CGPoint, in imageFrame: CGRect) -> CGPoint? {
        guard imageFrame.contains(point), imageFrame.width > 0, imageFrame.height > 0 else {
            return nil
        }

        let normalizedX = (point.x - imageFrame.minX) / imageFrame.width
        let normalizedY = (point.y - imageFrame.minY) / imageFrame.height
        return CGPoint(x: normalizedX, y: normalizedY)
    }

    static func denormalize(point: CGPoint, in imageFrame: CGRect) -> CGPoint {
        CGPoint(
            x: imageFrame.minX + (point.x * imageFrame.width),
            y: imageFrame.minY + (point.y * imageFrame.height)
        )
    }
}
