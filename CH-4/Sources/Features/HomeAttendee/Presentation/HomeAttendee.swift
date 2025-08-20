//
//  HomeAttendee.swift
//  CH-4
//
//  Created by Dwiki on 19/08/25.
//

import SwiftUI

struct HomeAttendee: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack {
            Text("Home Attendee")
            Button {
                appState.switchRole(to: appState.currentRole == .attendee ? .creator : .attendee)
            } label: {
                Text("Switch Role")
            }
        }

    }
}

#Preview {
    HomeAttendee()
}
