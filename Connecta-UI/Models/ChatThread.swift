//
//  ChatThread.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//
import Foundation

struct ChatThread: Identifiable {
    let id: UUID
    let participantName: String
    let lastMessage: String
    let lastUpdated: Date
    let unreadCount: Int
}

