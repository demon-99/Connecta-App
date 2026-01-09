//
//  ChatListView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct ChatsListView: View {
    @StateObject private var viewModel = ChatsListViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.chats) { chat in
                NavigationLink {
                    ChatView() // your existing ChatView
                } label: {
                    ChatRowView(chat: chat)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chats")
            .onAppear {
                viewModel.loadChats()
            }
        }
    }
}
