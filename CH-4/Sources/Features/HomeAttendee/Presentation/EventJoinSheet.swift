import SwiftUI

struct EventJoinSheet: View {
    let eventDetail: EventValidateModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 6)
                .padding(.top, 12)
            
            // Event image or placeholder
            AsyncImage(url: URL(string: eventDetail.photoLink)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            
            // Event details
            VStack(spacing: 16) {
                // Title
                Text("You're about to join")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(eventDetail.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)
                
                // Participants count
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                    Text("\(eventDetail.currentParticipant) participants")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                // Join button
                CustomButton(title: "Join Event", style: .primary) {
                    
                }
                // Cancel button
                CustomButton(title: "Cancel", style: .secondary) {
                    
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }
}
