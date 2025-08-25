import SwiftUI

struct ParticipantCard: View {
    var image: Image
    var name: String
    var title: String
    var onTap: () -> Void

    private let cardCornerRadius: CGFloat = 20
    private let cardPadding: CGFloat = 16

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    // Neon border effect
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 7
                        )
                        .blur(radius: 1)
                        .opacity(0.8)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)

            // Background image that fills the entire card
            image
                .resizable()
                .scaledToFill()
                .clipped()  // Clip to card bounds

            // Text overlay with gradient background
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Tap to see detail")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.top, 2)
            }
            .padding(cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                // Gradient overlay for text readability
                LinearGradient(
                    colors: [
                        .black.opacity(0.7),
                        .black.opacity(0.3),
                        .clear,
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .contentShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .padding()
        .onTapGesture(perform: onTap)
    }
}

// Alternative version with more flexible sizing
struct FlexibleParticipantCard: View {
    var image: AnyView
    var name: String
    var title: String
    var detailContent: AnyView
    var onTap: () -> Void

    private let cornerRadius: CGFloat = 20
    private let strokeWidth: CGFloat = 10
    @State private var isFlipped = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient stroke background (slightly larger)
                RoundedRectangle(cornerRadius: cornerRadius + strokeWidth)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 1)
                    .opacity(0.8)
                
                // Main card content
                if isFlipped {
                    // Back view (detail view)
                    backView
                } else {
                    // Front view (original card)
                    frontView(geometry: geometry)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius + strokeWidth))
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onTapGesture {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    isFlipped.toggle()
                }
                onTap()
            }
        }
        .aspectRatio(0.7, contentMode: .fit)
    }
    
    private func frontView(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Card background
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.06))
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)

            // Image fills entire available space
            image
                .scaledToFill()
                .frame(
                    width: geometry.size.width - strokeWidth * 2,
                    height: geometry.size.height - strokeWidth * 2
                )
                .clipped()

            // Text overlay
            textOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(strokeWidth) // Creates space for the stroke
    }
    
    private var backView: some View {
        ZStack {
            // Background for back view
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black.opacity(0.8))
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
            
            // Detail content
            detailContent
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // Flip the content back to readable
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .padding(strokeWidth)
    }

    private var textOverlay: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))

            Text("Tap to see detail")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    .black.opacity(0.7),
                    .black.opacity(0.3),
                    .clear,
                ],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
}
