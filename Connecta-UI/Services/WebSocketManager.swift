//
//  WebSocketManager.swift
//  Connecta-UI
//
//  Created by Nikhil on 13/01/26.
//



import Foundation
import Starscream
import Combine
class WebSocketManager: ObservableObject, WebSocketDelegate {
    
    static let shared = WebSocketManager()
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var connectionStatus: String = "Disconnected"
    
    // MARK: - Private Properties
    private var socket: WebSocket?
    private var currentUsername: String?
    private var subscriptions: [String: Int] = [:]
    private var nextSubscriptionId = 0
    
    // Callback for received messages
    var onMessageReceived: ((Message) -> Void)?
    
    private let baseURL = "ws://172.20.10.3:8080/ws" // Match your REST API base
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Connection Methods
    func connect(username: String) {
        guard socket == nil || !isConnected else {
            print("⚠️ Already connected")
            return
        }
        
        self.currentUsername = username
        
        guard let url = URL(string: baseURL) else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        
        print("🔌 Connecting to WebSocket: \(baseURL)")
        connectionStatus = "Connecting..."
    }
    
    func disconnect() {
        sendDisconnect()
        socket?.disconnect()
        socket = nil
        isConnected = false
        connectionStatus = "Disconnected"
        subscriptions.removeAll()
        print("🔌 Disconnected from WebSocket")
    }
    
    // MARK: - STOMP Protocol Methods
    private func sendConnect() {
        let connectFrame = """
        CONNECT
        accept-version:1.1,1.0
        heart-beat:10000,10000
        
        \u{0000}
        """
        
        socket?.write(string: connectFrame)
        print("📤 Sent CONNECT frame")
    }
    
    private func subscribeToPrivateMessages() {
        guard let username = currentUsername else { return }
        
        let subId = nextSubscriptionId
        nextSubscriptionId += 1
        
        let subscribeFrame = """
        SUBSCRIBE
        id:sub-\(subId)
        destination:/user/queue/messages
        
        \u{0000}
        """
        
        subscriptions["/user/queue/messages"] = subId
        socket?.write(string: subscribeFrame)
        print("📥 Subscribed to /user/queue/messages (id: sub-\(subId))")
    }
    
    private func subscribeToPublicMessages() {
        let subId = nextSubscriptionId
        nextSubscriptionId += 1
        
        let subscribeFrame = """
        SUBSCRIBE
        id:sub-\(subId)
        destination:/topic/public
        
        \u{0000}
        """
        
        subscriptions["/topic/public"] = subId
        socket?.write(string: subscribeFrame)
        print("📥 Subscribed to /topic/public (id: sub-\(subId))")
    }
    
    private func sendUserConnect() {
        guard let username = currentUsername else { return }
        
        let message = Message(
            id: UUID().uuidString,
            authorName: username,
            receiverName: "",
            message: "\(username) joined",
            timestamp: ISO8601DateFormatter().string(from: Date()),
            status: "SENT"
        )
        
        sendStompMessage(destination: "/app/user-connect", message: message)
        print("👋 Sent user connect notification")
    }
    
    private func sendDisconnect() {
        let disconnectFrame = """
        DISCONNECT
        
        \u{0000}
        """
        
        socket?.write(string: disconnectFrame)
        print("📤 Sent DISCONNECT frame")
    }
    
    // MARK: - Send Message
    func sendMessage(_ message: Message) {
        sendStompMessage(destination: "/app/private-message", message: message)
        print("📤 Sent message to \(message.receiverName)")
    }
    
    private func sendStompMessage(destination: String, message: Message) {
        guard let jsonData = try? JSONEncoder().encode(message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to encode message")
            return
        }
        
        let sendFrame = """
        SEND
        destination:\(destination)
        content-type:application/json
        content-length:\(jsonString.utf8.count)
        
        \(jsonString)\u{0000}
        """
        
        socket?.write(string: sendFrame)
    }
    
    // MARK: - WebSocket Delegate Methods
    // MARK: - WebSocket Delegate Methods
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(_):
            print("✅ WebSocket Connected")
            isConnected = true
            connectionStatus = "Connected"
            
            // Send STOMP CONNECT frame
            sendConnect()
            
            // Wait a bit for CONNECTED response, then subscribe
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.subscribeToPrivateMessages()
                self.subscribeToPublicMessages()
                self.sendUserConnect()
            }
            
        case .disconnected(let reason, let code):
            print("❌ WebSocket Disconnected: \(reason) (Code: \(code))")
            isConnected = false
            connectionStatus = "Disconnected"
            
        case .text(let text):
            print("📨 Received frame:\n\(text)")
            handleStompFrame(text)
            
        case .binary(let data):
            print("📦 Received binary data: \(data.count) bytes")
            
        case .error(let error):
            print("❌ WebSocket Error: \(error?.localizedDescription ?? "Unknown")")
            isConnected = false
            connectionStatus = "Error"
            
        case .cancelled:
            print("⚠️ WebSocket Cancelled")
            isConnected = false
            connectionStatus = "Cancelled"
            
        case .ping(_):
            print("🏓 Ping received")
            
        case .pong(_):
            print("🏓 Pong received")
            
        case .viabilityChanged(_):
            print("📶 Viability changed")
            
        case .reconnectSuggested(_):
            print("🔄 Reconnect suggested")
            
        case .peerClosed:
            print("👋 Peer closed connection")
            isConnected = false
            connectionStatus = "Peer Closed"
        }
    }
    
    // MARK: - STOMP Frame Handling
    private func handleStompFrame(_ frame: String) {
        let lines = frame.components(separatedBy: "\n")
        
        guard let command = lines.first else { return }
        
        switch command {
        case "CONNECTED":
            print("✅ STOMP Connected")
            
        case "MESSAGE":
            parseMessageFrame(frame)
            
        case "ERROR":
            print("❌ STOMP Error frame received")
            if let errorMessage = extractFrameBody(frame) {
                print("Error message: \(errorMessage)")
            }
            
        case "RECEIPT":
            print("✅ Receipt received")
            
        default:
            print("⚠️ Unknown STOMP command: \(command)")
        }
    }
    
    private func parseMessageFrame(_ frame: String) {
        guard let body = extractFrameBody(frame) else {
            print("⚠️ No body in MESSAGE frame")
            return
        }
        
        // Remove null terminator if present
        let cleanBody = body.trimmingCharacters(in: .controlCharacters)
        
        guard let data = cleanBody.data(using: .utf8) else {
            print("❌ Failed to convert body to data")
            return
        }
        
        do {
            let message = try JSONDecoder().decode(Message.self, from: data)
            print("✅ Decoded message from \(message.authorName): \(message.message)")
            
            DispatchQueue.main.async {
                self.onMessageReceived?(message)
            }
        } catch {
            print("❌ Failed to decode message: \(error)")
            print("Raw body: \(cleanBody)")
        }
    }
    
    private func extractFrameBody(_ frame: String) -> String? {
        let lines = frame.components(separatedBy: "\n")
        
        // Find empty line (separator between headers and body)
        if let emptyLineIndex = lines.firstIndex(where: { $0.isEmpty }) {
            let bodyLines = lines[(emptyLineIndex + 1)...]
            return bodyLines.joined(separator: "\n")
        }
        
        return nil
    }
}
