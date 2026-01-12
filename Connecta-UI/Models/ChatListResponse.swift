//
//  ChatListResponse.swift
//  Connecta-UI
//
//  Created by Nikhil on 13/01/26.
//

import Foundation

struct ChatListItem: Codable, Identifiable {
    let lastMessage: String
    let lastMessageTimestamp: String
    let messageStatus: String
    let receiverName: String
    
    // Computed property for SwiftUI List
    var id: String { receiverName }
    
    // Convert timestamp string to Date
    var timestamp: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: lastMessageTimestamp) ?? Date()
    }
}
