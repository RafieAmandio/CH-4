import SwiftUI

struct HomeCreatorView: View {
    @StateObject private var viewModel = HomeCreatorViewModel(showingProfile: false, showingCreate: false)
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Main Content")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Findect")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingCreate.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                    
                    Button(action: {
                        viewModel.showingProfile.toggle()
                    }) {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingProfile) {
            ProfileView()
        }
        .sheet(isPresented: $viewModel.showingCreate) {
            CreateEventView()
        }
    }
}

// Example views for the sheets
struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile View")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


// Alternative approach with custom toolbar items
struct CustomToolbarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Custom Toolbar Example")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Custom")
            .toolbar {
                // First bar - Primary actions
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button(action: {}) {
                            Image(systemName: "heart")
                        }
                    }
                }
                
                // Second bar - Secondary actions
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Option 1", action: {})
                        Button("Option 2", action: {})
                        Button("Option 3", action: {})
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// Using custom images instead of SF Symbols
struct CustomIconToolbarView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Custom Icons Example")
                    .font(.title)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Custom Icons")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        // You can use custom images from your bundle
                        Image("custom-icon-1") // Replace with your custom image
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    
                    Button(action: {}) {
                        Image("custom-icon-2") // Replace with your custom image
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16))
                    }
                }
            }
        }
    }
}


#Preview {
    HomeCreatorView()
}
