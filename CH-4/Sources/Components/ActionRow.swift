import SwiftUI
import UIComponentsKit

struct ActionRow: View {
    let title: String
    let systemName: String
    let action: () -> Void
    let width: CGFloat?
    
    init(title: String, systemName: String, width: CGFloat? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemName = systemName
        self.width = width
        self.action = action
    }
    
    var body: some View {
        CardView {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.primary.opacity(0.001)) // tap target
                    HStack(spacing: 20){
                        Image(systemName: systemName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                         Text(title)
                             .font(AppFont.bodySmallSemibold)
                         Spacer().frame(width: width)
                    }
                  
                }
                .frame(width: .infinity, height: 36)
                .foregroundColor(.white)
            }
        }

    }
}
