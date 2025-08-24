import SwiftUI
import UIComponentsKit

struct AppClipView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        
        switch appState.screen {
        case .appValue:
            AppValueView()
                .toolbar(.hidden, for: .navigationBar)  // just in case
                .navigationBarBackButtonHidden(true)
            
        case .updateProfile:
            UpdateProfileView()
                
        }
    }
}

#Preview {
    AppClipView()
        .environmentObject(AppStateManager.shared)
}
