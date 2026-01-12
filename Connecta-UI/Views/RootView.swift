//
//  RootView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }

            ProfileView(authVM: authVM)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
