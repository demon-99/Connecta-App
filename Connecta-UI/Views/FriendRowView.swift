//
//  FriendRowView.swift
//  Connecta-UI
//
//  Created by Nikhil on 13/01/26.
//

import SwiftUI
struct FriendRowView: View {
    let friend: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let urlString = friend.profilePicture,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    case .failure:
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(friend.username.prefix(1)).uppercased())
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(String(friend.username.prefix(1)).uppercased())
                            .foregroundColor(.white)
                            .font(.headline)
                    )
            }
            
            // Friend info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(friend.fullName.isEmpty ? friend.username : friend.fullName)
                        .font(.headline)
                    
                    if let isVerified = friend.isVerified, isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(friend.username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let bio = friend.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
