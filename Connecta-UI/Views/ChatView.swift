//
//  ChatView.swift
//  Connecta-UI
//
//  Updated to support WebSocket real-time messaging
//

import SwiftUI

struct ChatView: View {
    let receiverName: String
    
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText: String = ""
    @State private var showConnectionStatus = false
    @State private var showEmojiPicker = false
    @State private var showStickerPicker = false
    
    @ObservedObject private var wsManager = WebSocketManager.shared
    
    private var currentUserName: String {
        authVM.currentUser?.username ?? "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Connection Status Banner (Optional)
            if showConnectionStatus {
                connectionStatusBanner
            }
            
            // MARK: - Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    if viewModel.isLoadingHistory {
                        ProgressView("Loading messages...")
                            .padding()
                    } else {
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
                Menu {
                    Button("Stickers") { showStickerPicker = true }
                    Button("Emoji") { showEmojiPicker = true }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                
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
        .navigationBarItems(trailing: connectionStatusButton)
        .onAppear {
            loadChat()
            connectWebSocket()
        }
        .onDisappear {
            // Don't disconnect - keep WebSocket alive for other chats
        }
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPicker { emoji in
                messageText.append(emoji)
                showEmojiPicker = false
            }
        }
        .sheet(isPresented: $showStickerPicker) {
            StickerPicker { stickerId in
                sendSticker(stickerId)
                showStickerPicker = false
            }
        }
    }
    
    // MARK: - Connection Status Banner
    private var connectionStatusBanner: some View {
        HStack {
            Circle()
                .fill(wsManager.isConnected ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(wsManager.isConnected ? "Connected" : wsManager.connectionStatus)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: { showConnectionStatus = false }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Connection Status Button
    private var connectionStatusButton: some View {
        Button(action: { showConnectionStatus.toggle() }) {
            Circle()
                .fill(wsManager.isConnected ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
        }
    }
    
    // MARK: - Connect WebSocket
    private func connectWebSocket() {
        if !wsManager.isConnected {
            wsManager.connect(username: currentUserName)
            print("🔌 Connecting WebSocket for \(currentUserName)")
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
        
        // Clear input immediately
        messageText = ""
        
        // Send via ViewModel (handles WebSocket + REST fallback)
        viewModel.sendMessage(message: newMessage)
    }

    private func sendSticker(_ stickerId: String) {
        let newMessage = Message(
            id: UUID().uuidString,
            authorName: currentUserName,
            receiverName: receiverName,
            message: "sticker:\(stickerId)",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            status: "SENT"
        )
        viewModel.sendMessage(message: newMessage)
    }
}

// MARK: - Message Bubble View (Keep existing implementation)
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                bubbleContent
                
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

    @ViewBuilder
    private var bubbleContent: some View {
        if let stickerId = parseStickerId(message.message) {
            Text(stickerEmoji(for: stickerId))
                .font(.system(size: 56))
                .padding(6)
                .background(Color.clear)
        } else {
            Text(message.message)
                .padding(10)
                .foregroundColor(isCurrentUser ? .white : .black)
                .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(16)
        }
    }

    private func parseStickerId(_ text: String) -> String? {
        guard text.hasPrefix("sticker:") else { return nil }
        let id = String(text.dropFirst("sticker:".count))
        return id.isEmpty ? nil : id
    }

    private func stickerEmoji(for id: String) -> String {
        switch id {
        case "party": return "🥳"
        case "lol": return "😂"
        case "love": return "😍"
        case "fire": return "🔥"
        case "ok": return "👌"
        case "sad": return "😢"
        case "wow": return "🤯"
        case "thumbs": return "👍"
        default: return "✨"
        }
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

struct EmojiPicker: View {
    let onSelect: (String) -> Void

    private let emojis: [String] = ["😀", "😅", "😂", "😍", "😘", "😎", "😭", "😤", "🤯", "👍", "🙏", "🔥", "✨", "🎉", "💯", "❤️"]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                    ForEach(emojis, id: \.self) { e in
                        Button(action: { onSelect(e) }) {
                            Text(e)
                                .font(.system(size: 32))
                                .frame(maxWidth: .infinity, minHeight: 54)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Emoji")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StickerPicker: View {
    let onSelect: (String) -> Void
    private let stickers: [(id: String, preview: String)] = [
        ("party", "🥳"),
        ("lol", "😂"),
        ("love", "😍"),
        ("fire", "🔥"),
        ("ok", "👌"),
        ("sad", "😢"),
        ("wow", "🤯"),
        ("thumbs", "👍"),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(stickers, id: \.id) { s in
                        Button(action: { onSelect(s.id) }) {
                            VStack(spacing: 6) {
                                Text(s.preview).font(.system(size: 44))
                                Text(s.id).font(.caption).foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 96)
                            .background(Color(.systemGray6))
                            .cornerRadius(14)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Stickers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
