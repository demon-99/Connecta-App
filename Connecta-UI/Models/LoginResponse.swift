//
//  LoginResponse.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import Foundation

// Define the LoginResponseDto to match the backend response body
// If LoginResponseDto doesn't require MainActor, remove the annotation
struct LoginResponseDto: Codable {
    var message: String
    var userId: String?
    var username: String?
}
