//
//  ProfileView.swift
//  Connecta-UI
//
//  Created by Nikhil on 09/01/26.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authVM: AuthViewModel

    var body: some View {
        ScrollView {
            if let user = authVM.currentUser {
                VStack(spacing: 16) {

                    // MARK: - Profile Picture
                    if let urlString = user.profilePicture,
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
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }

                    // MARK: - Name & Username
                    VStack(spacing: 4) {
                        Text(user.fullName.isEmpty ? user.username : user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if let isVerified = user.isVerified, isVerified {
                            Text("✅ Verified")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    // MARK: - Bio
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // MARK: - Stats (Language & Theme)
                    HStack(spacing: 40) {
                        VStack {
                            Text(user.language ?? "-")
                                .font(.headline)
                            Text("Language")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        VStack {
                            Text(user.theme ?? "-")
                                .font(.headline)
                            Text("Theme")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .padding()
            } else {
                // Show a loading indicator if the profile is not yet fetched
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading profile...")
                        .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .navigationTitle("Profile")
    }
}

