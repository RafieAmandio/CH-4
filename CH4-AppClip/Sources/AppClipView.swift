import SwiftUI
import UIComponentsKit

struct AppClipView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
              
               
            Text("CH-4 App Clip Made by The Team")
                .font(AppFont.headingLarge)
            Text("This is the App Clip version of CH-4")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundStyle(AppColors.primary)
        .padding()
    }
}

#Preview {
    AppClipView()
} 
