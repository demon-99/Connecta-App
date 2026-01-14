//
//  ChatViewModel.swift
//  Connecta-UI
//
//  Updated to support both REST API and WebSocket
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var isLoadingHistory = false
    @Published var errorMessage: String?
    
    private let chatService = ChatService.shared
    private let wsManager = WebSocketManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupWebSocketListener()
    }
    
    // MARK: - Setup WebSocket Listener
    private func setupWebSocketListener() {
        // Listen for incoming WebSocket messages
        wsManager.onMessageReceived = { [weak self] message in
            guard let self = self else { return }
            
            // Check if message already exists (to avoid duplicates)
            if !self.messages.contains(where: { $0.id == message.id }) {
                self.messages.append(message)
                print("✅ Added WebSocket message to UI: \(message.message)")
            }
        }
    }
    
    // MARK: - Load Chat History (REST API)
    func loadChatHistory(authorName: String, receiverName: String) {
        isLoadingHistory = true
        errorMessage = nil
        
        chatService.getChatHistory(authorName: authorName, receiverName: receiverName) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoadingHistory = false
            
            switch result {
            case .success(let messages):
                self.messages = messages.sorted { $0.timestamp < $1.timestamp }
                print("✅ Loaded \(messages.count) messages from history")
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("❌ Failed to load chat history: \(error)")
            }
        }
    }
    
    // MARK: - Send Message (WebSocket + REST Fallback)
    func sendMessage(message: Message) {
        // Add message to UI immediately (optimistic update)
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
        }
        
        // Try WebSocket first if connected
        if wsManager.isConnected {
            print("📤 Sending via WebSocket")
            wsManager.sendMessage(message)
        } else {
            // Fallback to REST API
            print("📤 WebSocket not connected, using REST API")
            sendMessageToBackend(message: message)
        }
    }
    
    // MARK: - Send Message via REST API (Fallback)
    func sendMessageToBackend(message: Message) {
        chatService.sendMessage(message) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let sentMessage):
                print("✅ Message sent via REST API: \(sentMessage.message)")
                
                // Update message status if needed
                if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                    self.messages[index] = sentMessage
                }
                
            case .failure(let error):
                print("❌ Failed to send message via REST: \(error)")
                self.errorMessage = "Failed to send message"
                
                // Remove optimistic message on failure
                self.messages.removeAll { $0.id == message.id }
            }
        }
    }
    
    // MARK: - Clear Messages
    func clearMessages() {
        messages.removeAll()
    }
}
