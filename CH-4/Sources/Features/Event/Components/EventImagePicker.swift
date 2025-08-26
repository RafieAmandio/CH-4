import SwiftUI
import PhotosUI
import UIKit

struct EventImagePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        Button(action: {
            isShowingImagePicker = true
        }) {
            ZStack {
                if let selectedImage = selectedImage {
                    // Show selected image
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .clipped()
                        .overlay(
                            // Edit overlay
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isShowingImagePicker = true
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.selectedImage = nil
                                    }) {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                            }
                        )
                } else {
                    // Show placeholder content
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(Color(red: 0.33, green: 0.53, blue: 0.86))
                        
                        Text("Input Picture or Poster")
                            .font(
                                Font.custom("Urbanist", size: 17)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.55, green: 0.55, blue: 0.56))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(red: 0.13, green: 0.13, blue: 0.17))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.21, green: 0.21, blue: 0.21), lineWidth: 1)
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
