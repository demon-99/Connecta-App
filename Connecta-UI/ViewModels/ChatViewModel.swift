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
    
    private let service = ChatService.shared
    
    // ✅ Removed hardcoded authorName and receiverName
    
    func loadChatHistory(authorName: String, receiverName: String) {
        isLoading = true
        
        service.getChatHistory(
            authorName: authorName,
            receiverName: receiverName
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let messages):
                    self.messages = messages
                case .failure(let error):
                    print("Error loading chat:", error.localizedDescription)
                }
            }
        }
    }
    
    func sendMessageToBackend(message: Message) {
        service.sendMessage(message) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sentMessage):
                    print("Message sent successfully:", sentMessage)
                    // Optionally update the message in the list with the server response
                    if let index = self.messages.firstIndex(where: { $0.id == sentMessage.id }) {
                        self.messages[index] = sentMessage
                    }
                case .failure(let error):
                    print("Failed to send message:", error.localizedDescription)
                }
            }
        }
    }
}
