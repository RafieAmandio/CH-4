import SwiftUI
import FoundationExtras

struct AppClipView: View {
    // Example usage of the Card struct from FoundationExtras module
    let sampleCard = Card(number: "1234-5678-9012-3456")
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("CH-4 App Clip Made by The Team")
                .font(.title)
            Text("This is the App Clip version of CH-4")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Display the card number from FoundationExtras module
            Text("Card: \(sampleCard.number)")
                .font(.caption)
                .padding(.top)
        }
        .padding()
    }
}

#Preview {
    AppClipView()
} 
