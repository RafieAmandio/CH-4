//
//  OnBoardingView.swift
//  CH-4
//
//  Created by Dwiki on 21/08/25.
//

import SwiftUI
import UIComponentsKit

struct AppValueView: View {
    @EnvironmentObject private var appState: AppStateManager
    @State private var goNext = false
    private var items: [ListItem] = [
        ListItem(
            title: "Meet people with your interest",
            description:
                "Match with the right people to those share your goals",
            image: "charm_people"),
        ListItem(
            title: "Turn events into opportunities",
            description:
                "From partners to mentors, find the right connection",
            image: "handshake"),
        ListItem(
            title: "Make every moment count",
            description:
                "Make the most of your time at networking events",
            image: "clock"),
    ]

    var body: some View {
        VStack(alignment: .leading) {
            if #available(iOS 17.0, *) {
                Text("Unlock Networking potential with ")
                    .font(AppFont.interLargeSemiBold)
                    + Text("Findect.")
                    .foregroundStyle(LinearGradient.customGradient3)
                    .font(AppFont.interLargeSemiBold)
            } else {
                Text("Unlock Networking potential with Findect.")
                    .font(AppFont.interLargeSemiBold)
            }

            Image("talking")
                .frame(maxWidth: .infinity)
                .padding(.vertical)

            VStack(alignment: .center, spacing: 50) {
                VStack(alignment: .center, spacing: 20) {
                    ForEach(items) { item in
                        ListItemView(item: item)
                    }
                }
                CustomButton(title: "Continue", style: .newPrimary) {
                    appState.screen = .homeAttendee
                    appState.currentRole = .attendee
                    HapticManager.shared.trigger(.medium)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ListItemView: View {
    var item: ListItem
    var body: some View {
        HStack(alignment: .center) {
            Image(item.image)
            Image("lineicons:hand-shake")
                .frame(width: 22.8, height: 22.8)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(AppFont.interMidBold)

                Text(item.description)
                    .multilineTextAlignment(.leading)
                    .font(AppFont.interMidMedium)
                    .foregroundColor(AppColors.gray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .cornerRadius(10)
    }

}

struct ListItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var image: String
}

#Preview {
    AppValueView()
}

#Preview {
    ListItemView(
        item: ListItem(
            title: "Meet people with your interest",
            description:
                "Match with the right people— those who share your goals, interests, and collaboration potential.",
            image: "charm_people"))
}
