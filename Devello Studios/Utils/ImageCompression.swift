import UIKit

enum ImageCompression {
    static func jpegData(
        from image: UIImage,
        maxBytes: Int = 3_000_000,
        maxDimension: CGFloat = 2048
    ) -> Data? {
        let resized = resizeIfNeeded(image: image, maxDimension: maxDimension)
        var quality: CGFloat = 0.9
        var data = resized.jpegData(compressionQuality: quality)

        while let current = data, current.count > maxBytes, quality > 0.2 {
            quality -= 0.1
            data = resized.jpegData(compressionQuality: quality)
        }

        return data
    }

    private static func resizeIfNeeded(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
