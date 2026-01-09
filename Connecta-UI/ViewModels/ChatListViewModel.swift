//
//  ChatListViewModel.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import Foundation
import Combine

final class ChatsListViewModel: ObservableObject {
    @Published var chats: [ChatThread] = []

    func loadChats() {
        // Later replace with ChatService
        chats = [
            ChatThread(
                id: UUID(),
                participantName: "Bob",
                lastMessage: "Hey Alice!",
                lastUpdated: Date(),
                unreadCount: 2
            ),
            ChatThread(
                id: UUID(),
                participantName: "Charlie",
                lastMessage: "See you tomorrow",
                lastUpdated: Date().addingTimeInterval(-3600),
                unreadCount: 0
            )
        ]
    }
}
