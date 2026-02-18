import SwiftUI

struct ProofUploadView: View {
    @Environment(\.dismiss) var dismiss
    let onComplete: () -> Void
    
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    @State private var isUploading = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 30) {
                Text("Task Verification")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.accent)
                
                InfoCard {
                    VStack(spacing: 20) {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .cornerRadius(12)
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppColors.primary)
                                
                                Text("Take a photo proof of your completed task.")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.accent.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.primary.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingImagePicker = true }) {
                            Text(image == nil ? "Open Camera" : "Retake Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.secondary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                
                if image != nil {
                    Button(action: uploadProof) {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Submit Proof")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primary)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .disabled(isUploading)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    func uploadProof() {
        isUploading = true
        // Simulate compression and storage
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isUploading = false
            onComplete()
            dismiss()
        }
    }
}

// Simple ImagePicker wrapper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        picker.sourceType = .camera
        #endif
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}
