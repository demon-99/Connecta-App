//
//  Message.swift
//  Connecta-UI
//
//  Created by Nikhil on 08/01/26.
//
import Foundation




struct Message: Identifiable, Codable, Equatable {
    let id: String?
    let authorName: String
    let receiverName: String
    let message: String
    let timestamp: String
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case authorName
        case receiverName
        case message
        case timestamp
        case status
    }

    // MARK: - Custom initializer for creating messages
    init(
        id: String? = nil,
        authorName: String,
        receiverName: String,
        message: String,
        timestamp: String,
        status: String? = "SENT"
    ) {
        self.id = id
        self.authorName = authorName
        self.receiverName = receiverName
        self.message = message
        self.timestamp = timestamp
        self.status = status
    }

    // MARK: - Fix Swift 6 decoding concurrency issue
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        authorName = try container.decode(String.self, forKey: .authorName)
        receiverName = try container.decode(String.self, forKey: .receiverName)
        message = try container.decode(String.self, forKey: .message)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
}
