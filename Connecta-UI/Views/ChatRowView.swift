//
//  ChatRowView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct ChatRowView: View {
    let chat: ChatThread

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue)
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(chat.participantName.prefix(1)))
                        .foregroundColor(.white)
                        .font(.headline)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.participantName)
                    .font(.headline)

                Text(chat.lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(chat.lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)

                if chat.unreadCount > 0 {
                    Text("\(chat.unreadCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 6)
    }
}
