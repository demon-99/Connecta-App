//
//  User.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//


import Foundation

struct User: Codable, Identifiable {
    let userId: String
    let username: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let profilePicture: String?
    let bio: String?
    let isVerified: Bool?
    let phoneNumber: String?
    let language: String?
    let theme: String?
    let createdAt: String?
    let updatedAt: String?

    // Identifiable
    var id: String { userId }

    // Computed full name
    var fullName: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}
