import SwiftUI
import PhotosUI
import UIComponentsKit

// MARK: - Circular Image Picker Component
struct CircularImagePicker: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    let size: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let placeholderIcon: String
    let placeholderIconSize: CGFloat
    
    init(
        size: CGFloat = 200,
        borderColor: Color = .blue,
        borderWidth: CGFloat = 4,
        placeholderIcon: String = "person.circle.fill",
        placeholderIconSize: CGFloat = 80
    ) {
        self.size = size
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.placeholderIcon = placeholderIcon
        self.placeholderIconSize = placeholderIconSize
    }
    
    var body: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
                        .clipShape(Circle())
                } else {
                    // Placeholder
                    Image(systemName: placeholderIcon)
                        .font(.system(size: placeholderIconSize))
                        .foregroundColor(.gray)
                }
            }
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .photosPicker(
            isPresented: $isShowingImagePicker,
            selection: $photoPickerItem,
            matching: .images
        )
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}

// MARK: - Customizable Version with Binding
struct CircularImagePickerWithBinding: View {
    @Binding var selectedImage: UIImage?
    @State private var isShowingActionSheet = false
    @State private var isShowingImagePicker = false
    @State private var isShowingCamera = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    let onImageSelected: ((UIImage?) async -> Void)?
    let size: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let placeholderIcon: String
    let placeholderIconSize: CGFloat
    let backgroundColor: Color
    
    private func handleImageSelection(_ image: UIImage?) async {
        selectedImage = image
        await onImageSelected?(image)
    }
    
    init(
        selectedImage: Binding<UIImage?>,
        size: CGFloat = 200,
        borderColor: Color = AppColors.pickerBackground,
        borderWidth: CGFloat = 4,
        placeholderIcon: String = "person.circle.fill",
        placeholderIconSize: CGFloat = 30,
        backgroundColor: Color = Color.gray.opacity(0.2),
        onImageSelected: ((UIImage?) async -> Void)? = nil
    ) {
        self._selectedImage = selectedImage
        self.size = size
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.placeholderIcon = placeholderIcon
        self.placeholderIconSize = placeholderIconSize
        self.backgroundColor = backgroundColor
        self.onImageSelected = onImageSelected
    }
    
    var body: some View {
        Button(action: {
            isShowingActionSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)
                
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
                        .clipShape(Circle())
                } else {
                    // Placeholder
                    VStack(spacing: 8) {
                        Image(systemName: placeholderIcon)
                            .font(.system(size: placeholderIconSize))
                            .foregroundColor(.gray)
                        
                        Text("Tap to select photo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                // Camera icon overlay when image is selected
                if selectedImage != nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 26.5))
                                    .foregroundColor(borderColor)
                            }
                            .offset(x: -2, y: 8)
                        }
                    }
                    .frame(width: size, height: size)
                }
            }
            .overlay(
                Circle()
                    .stroke(borderColor, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose how you'd like to select your photo"),
                buttons: [
                    .default(Text("Camera")) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            sourceType = .camera
                            isShowingCamera = true
                        }
                    },
                    .default(Text("Photo Library")) {
                        isShowingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .photosPicker(
            isPresented: $isShowingImagePicker,
            selection: $photoPickerItem,
            matching: .images
        )
        .fullScreenCover(isPresented: $isShowingCamera) {
            ImagePicker(sourceType: sourceType, onImageSelected: { image in
                Task {
                    await handleImageSelection(image)
                }
            })
        }
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await handleImageSelection(uiImage)
                }
            }
        }
    }
}

// MARK: - Alternative with Image Picker Sheet (iOS 14+ compatible)
//struct CircularImagePickerSheet: View {
//    @State private var selectedImage: UIImage?
//    @State private var isShowingImagePicker = false
//    
//    let size: CGFloat
//    let borderColor: Color
//    let borderWidth: CGFloat
//    
//    init(
//        size: CGFloat = 200,
//        borderColor: Color = Color(red: 0.3, green: 0.7, blue: 1.0),
//        borderWidth: CGFloat = 4
//    ) {
//        self.size = size
//        self.borderColor = borderColor
//        self.borderWidth = borderWidth
//    }
//    
//    var body: some View {
//        Button(action: {
//            isShowingImagePicker = true
//        }) {
//            ZStack {
//                Circle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: size, height: size)
//                
//                if let selectedImage = selectedImage {
//                    Image(uiImage: selectedImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: size - borderWidth * 2, height: size - borderWidth * 2)
//                        .clipShape(Circle())
//                } else {
//                    Image(systemName: "person.circle.fill")
//                        .font(.system(size: 80))
//                        .foregroundColor(.gray)
//                }
//            }
//            .overlay(
//                Circle()
//                    .stroke(borderColor, lineWidth: borderWidth)
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//        .sheet(isPresented: $isShowingImagePicker) {
//            ImagePicker(selectedImage: $selectedImage)
//        }
//    }
//}

// MARK: - UIImagePickerController Wrapper (for iOS 14+)
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage?) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            parent.onImageSelected(image)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

