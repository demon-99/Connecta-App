//
//  ChatViewModel.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var isLoading = false
    
    private let service = ChatService()
    
    let authorName = "Alice"
    let receiverName = "Bob"
    
    func loadChat() {
        isLoading = true
        
        service.getChatHistory(
            authorName: authorName,
            receiverName: receiverName
        ) { result in
            self.isLoading = false
            
            switch result {
            case .success(let messages):
                self.messages = messages
            case .failure(let error):
                print("Error loading chat:", error)
            }
        }
    }
    func sendMessageToBackend(message: Message) {
            service.sendMessage(message) { result in
                switch result {
                case .success(let sentMessage):
                    print("Message sent successfully:", sentMessage)
                case .failure(let error):
                    print("Failed to send message:", error)
                }
            }
    }
}
