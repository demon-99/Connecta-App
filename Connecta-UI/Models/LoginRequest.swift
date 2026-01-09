//
//  LoginRequest.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import Foundation

// Define the LoginRequestDto to match the backend request body
struct LoginRequest: Codable {
    var usernameOrEmail: String
    var password: String
}
