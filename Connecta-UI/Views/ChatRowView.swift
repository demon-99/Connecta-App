//
//  ChatRowView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct ChatRowView: View {
    let chat: ChatListItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(chat.receiverName.prefix(1)).uppercased())
                        .foregroundColor(.white)
                        .font(.headline)
                )
            
            // Chat info
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.receiverName)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    // Status indicator
                    if chat.messageStatus == "SENT" {
                        Image(systemName: "checkmark")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else if chat.messageStatus == "DELIVERED" {
                        Image(systemName: "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    } else if chat.messageStatus == "READ" {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Timestamp
            VStack(alignment: .trailing, spacing: 4) {
                Text(chat.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
