import SwiftUI
import Foundation
import UIComponentsKit

@main
struct CH4App: App {
    @StateObject private var appState = AppStateManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColors.primary.edgesIgnoringSafeArea(.all)
                ContentView()
                    .preferredColorScheme(.light)
                    .background(AppColors.primary.ignoresSafeArea())
                    .environmentObject(appState)
            }
        }
    }
}


#Preview {
  @StateObject  var appState = AppStateManager()
    ZStack {
        AppColors.primary.edgesIgnoringSafeArea(.all)
        ContentView()
            .preferredColorScheme(.light)
            .background(AppColors.primary.ignoresSafeArea())
            .environmentObject(appState)
    }
}
