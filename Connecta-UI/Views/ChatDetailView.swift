//
//  ChatDetailView.swift
//  Connecta-UI
//
//  Created by Nikhil on 13/01/26.
//
import SwiftUI
struct ChatDetailView: View {
    let receiverName: String
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Chat with \(receiverName)")
                .font(.title)
            
            // You can integrate your existing chat view here
            Text("Chat messages will appear here")
                .foregroundColor(.gray)
        }
        .navigationTitle(receiverName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
