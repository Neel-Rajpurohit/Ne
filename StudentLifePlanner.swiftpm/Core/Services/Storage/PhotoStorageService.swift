import UIKit

@MainActor
class PhotoStorageService {
    static let shared = PhotoStorageService()
    
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func savePhoto(image: UIImage, for activityId: UUID) -> String? {
        guard let compressedData = ImageCompressor.compress(image: image) else { return nil }
        
        let fileName = "\(activityId.uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try compressedData.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving photo: \(error)")
            return nil
        }
    }
    
    func loadPhoto(path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deletePhoto(path: String) {
        let fileURL = URL(fileURLWithPath: path)
        try? fileManager.removeItem(at: fileURL)
    }
}
