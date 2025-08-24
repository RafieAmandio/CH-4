//
//  AppValueView.swift
//  CH-4
//
//  Created by Rafie Amandio F on 24/08/25.
//

import SwiftUI
import UIComponentsKit

struct AppValueView: View {
    @EnvironmentObject private var appState :AppStateManager
    @State private var goNext = false
    private var items: [ListItem] = [
        ListItem(
            title: "Meet people with your interest",
            description:
                "Match with the right people— those who share your goals, interests, and collaboration potential.",
            image: "talking"),
        ListItem(
            title: "Turn events into opportunities",
            description:
                "From partners to mentors, find the right connection while you’re here.",
            image: "handshake"),
        ListItem(
            title: "Make every moment count",
            description:
                "Match with the right people— those who share your goals, interests, and collaboration potential.",
            image: "clock"),
    ]

    var body: some View {
        ApplyBackground {
            VStack(spacing: 50) {
                Spacer()
                    .frame(height: 5)
                Text("Unlock Networking potential with Findect.")
                    .font(AppFont.headingLargeBold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 24) {
                    ForEach(items) { item in
                        ListItemView(item: item)
                    }
                }
                Spacer()
                CustomButton(title: "Continue", style: .primary) {
                }

            }
            .padding(.horizontal, 20)
        }

    }
}

struct ListItemView: View {
    var item: ListItem
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 67, height: 67, alignment: .leading)

            VStack(alignment: .leading, spacing: 10) {
                Text(item.title)
                    .font(AppFont.bodySmallBold)
                    .foregroundColor(.white)

                Text(item.description)
                    .multilineTextAlignment(.leading)
                    .font(AppFont.bodySmallRegular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
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
        item: ListItem(title: "clock", description: "test", image: "test"))
}
