//
//  EventDetailCard.swift
//  CH-4
//
//  Created by Dwiki on 22/08/25.
//

import SwiftUI

struct EventDetailCard: View {
    @State private var isFlipping = false
    
    var body: some View {
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 350)
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Card Content
            VStack(spacing: 20) {
                // Event Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 35, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Event Details
                VStack(spacing: 8) {
                    Text("Tech Conference 2024")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Join us for an amazing experience")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Label("Aug 25, 2025", systemImage: "calendar")
                        Spacer()
                        Label("2:00 PM", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }
                
                Spacer()
                
                // Join Button
                Button(action: {
                    // Add your join event action here
                    print("Joined the event!")
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 16, weight: .medium))
                        Text("Join Event")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 30)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            .padding(.vertical, 30)
        }
        .rotation3DEffect(
            .degrees(isFlipping ? 360 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.4), value: isFlipping)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFlipping = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        EventDetailCard()
    }
}
