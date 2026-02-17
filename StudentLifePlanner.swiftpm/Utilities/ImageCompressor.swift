import UIKit

struct ImageCompressor {
    static func compress(image: UIImage, maxFileSize: Int = 100 * 1024) -> Data? {
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.1
        var data = image.jpegData(compressionQuality: compression)
        
        while let imageData = data, imageData.count > maxFileSize && compression > 0 {
            compression -= step
            data = image.jpegData(compressionQuality: compression)
        }
        
        return data
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
