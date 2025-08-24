import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack {
                ProgressView().scaleEffect(1.5)
                Text("Loading...")
            }
        }
    }
}



extension View {
    func loading(_ isLoading: Bool) -> some View {
        ZStack {
            self.disabled(isLoading).opacity(isLoading ? 0.6 : 1.0)
            if isLoading { LoadingOverlay() }
        }
    }
}
