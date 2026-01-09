//
//  RootView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel  // ✅ Use the existing instance

    var body: some View {
        TabView {
            ChatsListView()
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }

            ProfileView(authVM: authVM)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

