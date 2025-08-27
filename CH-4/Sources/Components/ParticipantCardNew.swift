import SwiftUI
import UIComponentsKit

struct ParticipantCardNew: View {
    var image: Image
    var name: String
    var title: String
    var onTap: () -> Void

    private let cardCornerRadius: CGFloat = 20
    private let cardPadding: CGFloat = 20
    private let imageCornerRadius: CGFloat = 15

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: 157.59108, height: 156.07867)
                .position(x: 245.564, y: 19.767)
            VStack(alignment: .leading, spacing: 0) {
                // Header section with name and title
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, cardPadding)
                .padding(.top, cardPadding)
                .padding(.bottom, 16)

                // Image section
                image
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .cornerRadius(imageCornerRadius)
                    .padding(.horizontal, cardPadding)

                // Footer section
                HStack(alignment: .center) {
                    Text("Tap to see detail")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.horizontal, cardPadding)
                .padding(.top, 12)
                .padding(.bottom, cardPadding)
            }
            .contentShape(RoundedRectangle(cornerRadius: cardCornerRadius))
            .onTapGesture(perform: onTap)
        }
        .frame(width: 477.03223, height: 654.07477)
    }
}

// Updated flexible version with flip animation
struct FlexibleParticipantCardNew: View {
    var image: AnyView
    var name: String
    var title: String
    var goal: String?
    var connectText: String?
    var keyReasons: [String]
    var onTap: () -> Void
    var detailContent: AnyView?

    private let cornerRadius: CGFloat = 18.8
    @State private var isFlipped = false
    private let strokeWidth: CGFloat = 25

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.cardBackground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isFlipped {
                    // Back view (detail view)
                    backView(geometry: geometry)
                } else {
                    // Front view (original card)
                    frontView(geometry: geometry)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .onTapGesture {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()

                withAnimation(.easeInOut(duration: 0.6)) {
                    isFlipped.toggle()
                }
                onTap()
            }
        }
        .aspectRatio(0.7, contentMode: .fit)  // Changed from 0.7 to 0.6 to make card taller
       
    }

    private func frontView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(AppFont.cardHead1)
                    .foregroundStyle(AppColors.cardTextDetails)

                Text(title)
                    .font(AppFont.cardDetail)
                    .foregroundStyle(AppColors.cardTextDetails)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            // Image section - calculate available space
            let headerHeight: CGFloat = 80  // Approximate header height
            let footerHeight: CGFloat = 50  // Approximate footer height
            let availableImageHeight =
                geometry.size.height - headerHeight - footerHeight

            image
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: geometry.size.width - 40,
                    height: availableImageHeight
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 20)

            Spacer(minLength: 10)

            // Footer
            Text("Tap to see detail")
                .font(AppFont.cardTap)
                .foregroundStyle(AppColors.cardTap.opacity(1))
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
    }

    private func backView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(AppFont.cardHead1)
                        .foregroundStyle(.white)
                    Text(title)
                        .font(AppFont.cardDetail)
                        .foregroundStyle(AppColors.cardTextDetails)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Detail content
                detailContent
            }
            .padding(20)
            .frame(maxWidth: geometry.size.width)
            .frame(minHeight: geometry.size.height - 40)  // Ensure it fills the available space
        }
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))  // Flip content back to readable
    }
}

// Example detail view that matches your target UI
struct DetailContentView: View {
    let goal: String
    let connectText: String?
    let keyReasons: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Goal section
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal")
                    .font(AppFont.cardHead2)
                    .foregroundStyle(.white)

                Text(goal)
                    .font(AppFont.cardText)
                    .foregroundStyle(AppColors.cardTextDetails)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white, lineWidth: 1)
                    )
            }

            // Connect section
            if let connectText = connectText {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connect")
                        .font(AppFont.cardHead2)
                        .foregroundStyle(.white)

                    HStack {
                        Image(systemName: "link")
                            .font(AppFont.cardText)
                            .foregroundStyle(.blue)
                        Text(connectText)
                            .font(AppFont.cardText)
                            .foregroundStyle(.blue)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.blue)
                            .font(AppFont.cardText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.blue, lineWidth: 1)
                    )
                }
            }

            // Key Reasons section
            if !keyReasons.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Reason")
                        .font(AppFont.cardHead2)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(keyReasons, id: \.self) { reason in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(AppFont.cardText)
                                    .foregroundStyle(.white)

                                Text(reason)
                                    .font(AppFont.cardText)
                                    .foregroundStyle(.white)
                                    .fixedSize(
                                        horizontal: false, vertical: true)

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview("Front View") {
    FlexibleParticipantCardNew(
        image: AnyView(
            Image("abg")
                .resizable()
        ),
        name: "Leonie Marie Gogh",
        title: "Technopreneur",
        goal: "Networking",
        connectText: "LinkedIn Profile",
        keyReasons: [
            "Kenan is also a CEO seeking investors, you both share similar goals",
            "His focus on scaling marketing and sales in technology sector aligns with your goal",
        ],
        onTap: {},
        detailContent: AnyView(
            DetailContentView(
                goal: "Technopreneur",
                connectText: "LinkedIn Profile",
                keyReasons: [
                    "Kenan is also a CEO seeking investors, you both share similar goals",
                    "His focus on scaling marketing and sales in technology sector aligns with your goal",
                ]
            )
        )
    )
    .frame(height: 475)
}

#Preview("Simple Card") {
    ParticipantCardNew(
        image: Image(systemName: "person.fill"),
        name: "Leonie Marie Gogh",
        title: "Technopreneur",
        onTap: {}
    )
    .frame(width: 280, height: 420)
    .background(Color.gray.opacity(0.1))
}
