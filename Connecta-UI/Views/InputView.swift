//
//  InputView.swift
//  Connecta-UI
//
//  Created by Nikhil on 12/01/26.
//

import SwiftUI


struct InputView: View {
    let placeholder: String
    var isSecureField: Bool = false
    @Binding var text: String
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.1))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Text Field
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
            } else {
                TextField(placeholder, text: $text)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
            }
        }
        .frame(height: 55) // Tinder-style height
        .padding(.horizontal, 30) // Align with other views
    }
}


