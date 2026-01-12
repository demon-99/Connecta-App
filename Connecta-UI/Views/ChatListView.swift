//
//  ChatListView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var chatList: [ChatListItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading chats...")
                        .padding()
                } else if !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadChats()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if chatList.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "message")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No chats yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Start a conversation to see it here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List(chatList) { chat in
                        NavigationLink(destination: ChatView(receiverName: chat.receiverName)) {
                            ChatRowView(chat: chat)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Messages")
            .navigationBarItems(trailing: Button(action: loadChats) {
                Image(systemName: "arrow.clockwise")
            })
            .onAppear {
                loadChats()
            }
        }
    }
    
    private func loadChats() {
        guard let user = authVM.currentUser else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        ChatService().getChatList(userName: user.username) { result in
            isLoading = false
            
            switch result {
            case .success(let chats):
                chatList = chats.sorted { $0.timestamp > $1.timestamp }
            case .failure(let error):
                errorMessage = "Failed to load chats: \(error.localizedDescription)"
            }
        }
    }
}


