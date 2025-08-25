import SwiftUI
import Foundation
import UIComponentsKit

@main
struct CH4App: App {

    var body: some Scene {
        WindowGroup {
            ZStack {
                Rectangle()
                    .fill(AppColors.offBlack)
                    .ignoresSafeArea()
                ContentView()
                    .preferredColorScheme(.dark)
                    .environmentObject(AppStateManager.shared)
            }
        }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(AppColors.offBlack)
            .ignoresSafeArea()
        ContentView()
            .preferredColorScheme(.dark)
            .environmentObject(AppStateManager.shared)
    }
}


extension LinearGradient {
    static let customGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "B863FF"), location: 0.0),   // 0%
            .init(color: Color(hex: "514FD0"), location: 0.35),  // Move cyan earlier (was 0.23)
            .init(color: Color(hex: "3B45B4"), location: 0.56),  // Move purple earlier (was 0.42)
            .init(color: Color(hex: "112C71"), location: 1.00),  // Move blue earlier (was 0.65)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    
    static let customGradient2 = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hex: "56E0E8"), location: 0.08),
            .init(color: Color(hex: "B963FF"), location: 0.35),
            .init(color: Color(hex: "5C58EA"), location: 0.55),
            .init(color: Color(hex: "112C71"), location: 1.0)
        ]),
        startPoint: UnitPoint(x: 2.5, y: 0.0) ,  // Start beyond bottom-right
        endPoint:UnitPoint(x: 1.3, y: 1.2)   // End beyond top-left
    )
    
    
}
