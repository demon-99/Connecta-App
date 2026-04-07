//
//  UserProfileResponseDto.swift
//  Connecta-UI
//
//  Created by Nikhil on 14/01/26.
//
import Foundation

struct UserProfileResponseDto: Codable {
    var userId: String
    var username: String
    var firstName: String
    var lastName: String
    var profilePicture: String?
    var bio: String?  // Make this optional
    var isVerified: Bool
    var phoneNumber: String?
    var lastLogin: Date
    var isActive: Bool
    var isOnline: Bool
    var isPrivate: Bool
}

