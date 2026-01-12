//
//  FriendDetailView.swift
//  Connecta-UI
//
//  Created by Nikhil on 13/01/26.
//

import SwiftUI
struct FriendDetailView: View {
    let friend: User
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Picture
                if let urlString = friend.profilePicture,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text(String(friend.username.prefix(1)).uppercased())
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(String(friend.username.prefix(1)).uppercased())
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        )
                }
                
                // Name & Username
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Text(friend.fullName.isEmpty ? friend.username : friend.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let isVerified = friend.isVerified, isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("@\(friend.username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Bio
                if let bio = friend.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    NavigationLink(destination: ChatView(receiverName: friend.username)) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("Message")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // Remove friend action
                    }) {
                        Image(systemName: "person.badge.minus")
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
