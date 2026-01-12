//
//  ChatView.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//

import SwiftUI

struct ChatView: View {
    let receiverName: String
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    
    private var currentUserName: String {
        authVM.currentUser?.username ?? "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.messages) { msg in
                            MessageBubble(
                                message: msg,
                                isCurrentUser: msg.authorName.lowercased() == currentUserName.lowercased()
                            )
                            .id(msg.id)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // MARK: - Signal-style Input Bar
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                    
                    HStack {
                        TextField("Message", text: $messageText)
                            .padding(10)
                            .disableAutocorrection(true)
                        
                        if !messageText.isEmpty {
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 44)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color(.systemBackground))
        }
        .navigationBarTitle(receiverName, displayMode: .inline)
        .onAppear {
            loadChat()
        }
    }
    
    // MARK: - Load Chat
    private func loadChat() {
        let author = currentUserName
        let receiver = receiverName
        viewModel.loadChatHistory(authorName: author, receiverName: receiver)
    }
    
    // MARK: - Send Message
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            authorName: currentUserName,
            receiverName: receiverName,
            message: messageText,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            status: "SENT"
        )
        
        viewModel.messages.append(newMessage)
        messageText = ""
        
        viewModel.sendMessageToBackend(message: newMessage)
    }
}

// MARK: - Message Bubble View
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .padding(10)
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(16)
                
                HStack(spacing: 4) {
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if isCurrentUser {
                        statusTickIcon(status: message.status ?? "SENT")
                            .font(.caption2)
                    }
                }
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal, 8)
    }
    
    private func formatTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            return displayFormatter.string(from: date)
        }
        return ""
    }
    
    @ViewBuilder
    private func statusTickIcon(status: String) -> some View {
        switch status.uppercased() {
        case "SENT":
            Image(systemName: "checkmark")
                .foregroundColor(.gray)
        case "DELIVERED":
            Image(systemName: "checkmark")
                .foregroundColor(.gray)
        case "READ":
            Image(systemName: "checkmark.double")
                .foregroundColor(.blue)
        default:
            EmptyView()
        }
    }
}
