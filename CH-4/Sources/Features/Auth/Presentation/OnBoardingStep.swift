import SwiftUI
import UIComponentsKit

// MARK: - OnboardingStep Model
struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: LinearGradient
    let currentStepIndex: Int
    let totalSteps: Int
}

// MARK: - Sample Data
extension OnboardingStep {
    static let sampleSteps: [OnboardingStep] = [
        OnboardingStep(
            title: "Find Shared Interests",
            description: "Get matched with attendees who align with your goals.",
            imageName: "people_talking", // Your custom image name
            backgroundColor: LinearGradient.customGradient2,
            currentStepIndex: 0,
            totalSteps: 3
        ),
        OnboardingStep(
            title: "Events to opportunities",
            description: "From partners to mentors, find the right connection while you're here.",
            imageName: "handshake", // Your custom image name
            backgroundColor: LinearGradient.customGradient2, // Purple gradient middle
            currentStepIndex: 1,
            totalSteps: 3
        ),
        OnboardingStep(
            title: "Make time matter",
            description: "Spend less time searching for the right conversation, use Findect. people suggestion",
            imageName: "clock", // Your custom image name
            backgroundColor: LinearGradient.customGradient2, // Purple gradient end
            currentStepIndex: 2,
            totalSteps: 3
        )
    ]
}

// MARK: - OnboardingStepView
struct OnboardingStepView: View {
    let step: OnboardingStep
 
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Main Content
            VStack(spacing: 20) {
                // Illustration
                IllustrationView(imageName: step.imageName)

                // Content
                VStack(spacing: 8) {
                    Text(step.title)
                        .font(AppFont.headingLargeBold)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(step.description)
                        .font(AppFont.bodySmallRegular)
                        .foregroundColor(.white)
    
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 32)
            }
    
        }

    }
}

// MARK: - Supporting Views
struct IllustrationView: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 200)
            .padding(.horizontal, 40)
    }
}

struct PageIndicatorView: View {
    let currentIndex: Int
    let totalCount: Int
    
    var body: some View {
        HStack(spacing: 25) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? AppColors.primary : Color.white)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
            }
        }
    }
}

struct ActionButtonsView: View {
    let onSignUp: () -> Void
    let onSignIn: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Sign Up Button
            Button(action: onSignUp) {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.headline)
                    Text("Sign Up with Apple")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue.opacity(0.9))
                .cornerRadius(25)
            }
            
            // Sign In Link
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.white.opacity(0.7))
                Button("Sign In", action: onSignIn)
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            .font(.subheadline)
        }
    }
}
